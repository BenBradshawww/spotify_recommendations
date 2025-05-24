import boto3
import os
import traceback
import psycopg2
from sshtunnel import SSHTunnelForwarder
from psycopg2.extras import execute_values, Json
import logging
from spotipy import Spotify
from spotipy.oauth2 import SpotifyClientCredentials
import dotenv
import json

from utilities import get_public_ip, upload_rows_to_postgres, create_spotify_client
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
def get_track_metadata(tracks: list[str]) -> list[tuple[str, str, str, str, str, str, str, str]]:

    n = len(tracks)
    tracks_meta_data:list[tuple[str, str, str, str, str, str, str, str]] = []

    for i in range(0, n, 50):
        logger.info(f"Getting metadata for {i} to {min(i + 50, n)} of {n} tracks...")
        section = tracks[i: i + 50]
        response = sp.tracks(section)

        for track in response["tracks"]:
            track_meta_data = (
                track["id"],
                track["name"],
                track["album"]["id"],
                track["album"]["name"],
                json.dumps([a["id"] for a in track["artists"]]),
                json.dumps([a["name"] for a in track["artists"]]),
                track["album"]["release_date"],
                track["duration_ms"],
                track["track_number"],
                track["popularity"]
            )
            tracks_meta_data.append(track_meta_data)

    return tracks_meta_data

def get_track_ids():
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

                sql_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "sql", "get_track_ids_without_meta_data.sql")
                sql = open(sql_path, "r").read()

                with conn.cursor() as cur:
                    cur.execute(sql)
                    track_ids = cur.fetchall()
                    return [track_id[0] for track_id in track_ids]
    except Exception as e:
        logger.error(traceback.format_exc())
        raise e


    
# ----------------------------
# Main function
# ----------------------------
def upload_track_meta_data():
    
    global sp
    sp = create_spotify_client()

    # Get track ids
    logger.info("Getting track ids for tracks with no metadata")
    tracks = get_track_ids()

    logger.info(f"Found {len(tracks)} tracks with no metadata.")

    # Get track metadata
    logger.info("Getting track metadata...")
    tracks_meta_data = get_track_metadata(tracks)

    # Upload track metadata to db
    logger.info("Uploading track metadata to db...")
    sql_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "sql", "insert_track_meta_data.sql")
    upload_rows_to_postgres(tracks_meta_data, sql_path)

    logger.info("Done!")
    
if __name__ == "__main__":
    upload_track_meta_data()