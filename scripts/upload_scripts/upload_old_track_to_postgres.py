import boto3
import os
import traceback
import psycopg2
from sshtunnel import SSHTunnelForwarder
from psycopg2.extras import execute_values
import logging
import dotenv
import json

from utilities import get_public_ip

# ----------------------------
# Load environment variables
# ----------------------------
dotenv.load_dotenv()


# ----------------------------
# Constants
# ----------------------------

SOURCE_BUCKET_NAME = 'ben-spotify'
SOURCE_BUCKET_PREFIX = 'recently_played_tracks'

OUTPUT_BUCKET_NAME = 'ben-spotify'
OUTPUT_BUCKET_PREFIX = 'recently_played_tracks_processed'


# ----------------------------
# Logging
# ----------------------------
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# ----------------------------
# Create clients
# ----------------------------
s3 = boto3.client('s3')
ec2 = boto3.client('ec2')

# ----------------------------
# Helper functions
# ----------------------------
    

def read_local_old_tracks(file) -> list[tuple[str, str, str, str, str, str, str, str, str, str, str, str, str]]:
    with open(file, 'r') as temp_file:
        data = json.load(temp_file)

        set_of_times:set[str] = set()
        rows:list[tuple[str, str, str, str, str, str, str, str, str, str, str, str, str]] = []
        for item in data:
            if item['spotify_track_uri'] is None:
                continue
        
            if item['ts'] in set_of_times:
                continue
            else:
                set_of_times.add(item['ts'])

            rows.append((
                item['spotify_track_uri'].split(':')[-1],
                item['ts'],
                item['master_metadata_album_artist_name'],
                item['master_metadata_track_name'],
                item['master_metadata_album_album_name'],
                item['ms_played'],
                item['reason_start'],
                item['reason_end'],
                item['shuffle'],
                item['skipped'],
                item['offline'],
            ))
        
        return rows

def insert_to_db(cur, rows):
    try:
                        
        columns = ", ".join([
            "spotify_old_tracks_track_id",
            "spotify_old_tracks_played_at",
            "spotify_old_tracks_artist_name",
            "spotify_old_tracks_track_name",
            "spotify_old_tracks_album_name",
            "spotify_old_tracks_ms_played",
            "spotify_old_tracks_reason_start",
            "spotify_old_tracks_reason_end",
            "spotify_old_tracks_shuffle",
            "spotify_old_tracks_skipped",
            "spotify_old_tracks_offline",
        ])

        sql = f"""
            INSERT INTO spotify_old_tracks ({columns}) VALUES %s
            ON CONFLICT (spotify_old_tracks_played_at) 
            DO UPDATE SET spotify_old_tracks_updated_at = CURRENT_TIMESTAMP
        """

        execute_values(cur, sql, rows)

        logger.info(f"Inserted {len(rows)} rows into spotify_old_tracks")
    except Exception as e:
        logger.error(f"Error inserting rows into spotify_old_tracks: {e}")
        raise e

# ----------------------------
# Main function
# ----------------------------
def upload_last_songs_to_db():
    try:
        with SSHTunnelForwarder(
            (get_public_ip(), 22),
            ssh_username='ec2-user',
            ssh_pkey=os.getenv("SSH_KEY_PATH"),
            remote_bind_address=('localhost', 5432),
            local_bind_address=('localhost', 5434)
        ) as tunnel:
            conn = psycopg2.connect(
                dbname='spotify',
                user='postgres',
                password=os.environ.get("POSTGRES_PASSWORD"),
                host='localhost',
                port=tunnel.local_bind_port
            )
            with conn.cursor() as cur:
                for file in os.listdir("./data/old_tracks"):
                    file_path = os.path.join("./data/old_tracks", file)
                    rows = read_local_old_tracks(file_path)
                    logger.info(f"Inserting {file} to db")
                    insert_to_db(cur, rows)

                conn.commit()
    except Exception as e:
        logger.error(traceback.format_exc())
        raise Exception(f"Error uploading old tracks to db: {e}")
    
if __name__ == "__main__":
    upload_last_songs_to_db()
