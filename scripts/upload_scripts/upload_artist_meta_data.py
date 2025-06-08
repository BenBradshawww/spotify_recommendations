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

from utilities import get_public_ip, upload_rows_to_postgres, create_spotify_client, get_db_connection


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
def get_artist_metadata(artists: list[str]) -> list[tuple[str, str, str, str, str, str, str, str]]:

    n = len(artists)
    artists_meta_data:list[tuple] = []

    for i in range(0, n, 50):
        logger.info(f"Getting metadata for {i} to {min(i + 50, n)} of {n} artists...")
        section = artists[i: i + 50]
        response = sp.artists(section)

        for artist in response["artists"]:
            artist_meta_data = (
                artist["id"],
                artist["name"],
                artist["followers"]["total"],
                artist["popularity"],
                json.dumps(artist["genres"]),
            )
            artists_meta_data.append(artist_meta_data)

    return artists_meta_data

def get_artist_ids():
    conn, tunnel = get_db_connection()
    try:
        sql_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "sql", "get_artist_ids_without_meta_data.sql")
        sql = open(sql_path, "r").read()

        with conn.cursor() as cur:
            cur.execute(sql)
            artist_ids = cur.fetchall()
            return [artist_id[0] for artist_id in artist_ids]
    except Exception as e:
        logger.error(traceback.format_exc())
        raise e
    finally:
        if tunnel:
            tunnel.stop()

    
# ----------------------------
# Main function
# ----------------------------
def upload_artist_meta_data():
    
    global sp
    sp = create_spotify_client()

    # Get track ids
    logger.info("Getting track ids for tracks with no metadata")
    artists = get_artist_ids()

    logger.info(f"Found {len(artists)} artists with no metadata.")

    # Get track metadata
    logger.info("Getting artist metadata...")
    artists_meta_data = get_artist_metadata(artists)

    # Upload track metadata to db
    logger.info("Uploading artist metadata to db...")
    sql_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "sql", "insert_artist_meta_data.sql")
    upload_rows_to_postgres(artists_meta_data, sql_path)

    logger.info("Done!")
    
if __name__ == "__main__":
    upload_artist_meta_data()