import boto3
import os
import traceback
import psycopg2
from sshtunnel import SSHTunnelForwarder
import logging
import dotenv
import json

from utilities import upload_rows_to_postgres, create_spotify_client, normalize_date
# ----------------------------
# Load environment variables
# ----------------------------
dotenv.load_dotenv()


# ----------------------------
# Logging
# ----------------------------
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# ----------------------------
# Create clients
# ----------------------------
ec2 = boto3.client('ec2')

# ----------------------------
# Helper functions
# ----------------------------
def get_album_metadata(albums: list[str]) -> list[tuple]:

    n = len(albums)
    albums_meta_data:list[tuple] = []

    for i in range(0, n, 20):
        logger.info(f"Getting metadata for {i} to {min(i + 20, n)} of {n} albums...")
        section = albums[i: i + 20]
        response = sp.albums(section)

        for album in response["albums"]:
            album_meta_data = (
                album["id"],
                album["name"],
                normalize_date(album["release_date"]),
                album["total_tracks"],
                album["album_type"],
                json.dumps([a["id"] for a in album["artists"]]),
                json.dumps([a["name"] for a in album["artists"]]),
                album["label"],
                album["popularity"],
            )
            albums_meta_data.append(album_meta_data)

    return albums_meta_data


def get_album_ids():
    try:
        with SSHTunnelForwarder(
                (os.getenv("TAILSCALE_IP"), 22),
                ssh_username='ec2-user',
                ssh_pkey=os.getenv("SSH_KEY_PATH"),
                remote_bind_address=('localhost', 5432),
                local_bind_address=('localhost', 5434)
            ) as tunnel:
                conn = psycopg2.connect(
                    dbname='spotify',
                    user='postgres',
                    password=os.getenv("POSTGRES_PASSWORD"),
                    host='localhost',
                    port=tunnel.local_bind_port
                )

                sql_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "sql", "get_album_ids_without_meta_data.sql")
                sql = open(sql_path, "r").read()

                with conn.cursor() as cur:
                    cur.execute(sql)
                    artist_ids = cur.fetchall()
                    return [artist_id[0] for artist_id in artist_ids]
    except Exception as e:
        logger.error(traceback.format_exc())
        raise e


    
# ----------------------------
# Main function
# ----------------------------
def upload_album_meta_data():
    
    global sp
    sp = create_spotify_client()

    # Get album ids
    logger.info("Getting album ids for albums with no metadata...")
    albums = get_album_ids()

    logger.info(f"Found {len(albums)} albums with no metadata.")

    # Get album metadata
    logger.info("Getting album metadata...")
    albums_meta_data = get_album_metadata(albums)

    # Upload album metadata to db
    logger.info("Uploading album metadata to db...")
    sql_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "sql", "insert_album_meta_data.sql")
    upload_rows_to_postgres(albums_meta_data, sql_path)

    logger.info("Done!")
    
if __name__ == "__main__":
    upload_album_meta_data()
