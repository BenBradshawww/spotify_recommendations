import os
import logging
import traceback
import tempfile
import csv

import boto3
import dotenv
import psycopg2
from tqdm import tqdm
from sshtunnel import SSHTunnelForwarder
from psycopg2.extras import execute_values

from utilities import get_public_ip, get_db_connection


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
def list_files_in_s3():
    response = s3.list_objects_v2(Bucket=SOURCE_BUCKET_NAME, Prefix=SOURCE_BUCKET_PREFIX)
    files = [file.get('Key') for file in response.get('Contents', [])]
    sorted_files = sorted(files, key=lambda x: x.split('/')[-1])
    return sorted_files


def insert_file_to_db(cur, temp_file_path):
    try:
        with open(temp_file_path, 'r') as temp_file:
            reader = csv.reader(temp_file)
            next(reader, None)
            rows = [tuple(row) for row in reader]
        
        cur.execute("SHOW search_path")
        sp = cur.fetchone()[0]
        logger.info(f"Postgres search_path is: {sp!r}")

        cur.execute("SELECT current_database()")
        db = cur.fetchone()[0]
        logger.info(f"Connected to database: {db!r}")
                            
        columns = ", ".join([
            "spotify_recent_tracks_track_played_at",
            "spotify_recent_tracks_track_id",
            "spotify_recent_tracks_artist_name",
            "spotify_recent_tracks_track_name",
        ])

        sql = f"""
            INSERT INTO spotify_recent_tracks ({columns}) VALUES %s
            ON CONFLICT (spotify_recent_tracks_track_played_at) 
            DO UPDATE SET spotify_recent_tracks_updated_at = CURRENT_TIMESTAMP
        """

        execute_values(cur, sql, rows)

        logger.info(f"Inserted {len(rows)} rows into spotify_recent_tracks")
    except Exception as e:
        logger.error(f"Error inserting rows into spotify_recent_tracks: {e}")
        raise e

def move_to_processed_folder(source_key: str):
    """
    Move an object within the same S3 bucket from source_key to dest_key.
    """
    try:
        # 1. Copy the object to new key
        copy_source = {'Bucket': SOURCE_BUCKET_NAME, 'Key': source_key}
        dest_key = f"{OUTPUT_BUCKET_PREFIX}/{source_key.split('/')[-1]}"
        s3.copy_object(Bucket=OUTPUT_BUCKET_NAME, CopySource=copy_source, Key=dest_key)

        # 2. Delete the original object
        s3.delete_object(Bucket=SOURCE_BUCKET_NAME, Key=source_key)
    except Exception as e:
        logger.error(f"Error moving {source_key} to {OUTPUT_BUCKET_PREFIX}{source_key}: {e}")
        raise


# ----------------------------
# Main function
# ----------------------------
def upload_recent_tracks_to_db():
    conn, tunnel = get_db_connection()
    
    try:
        with conn.cursor() as cur:
            for key in tqdm(list_files_in_s3()):
                with tempfile.TemporaryDirectory() as temp_dir:
                    temp_file_path = os.path.join(temp_dir, "temp.csv")
                    # Download the S3 object to the temporary file
                    logger.info(f"Downloading {key} to {temp_file_path}")
                    s3.download_file(Bucket=SOURCE_BUCKET_NAME, Key=key, Filename=temp_file_path)
                    
                    # Read the CSV into a pandas DataFrame
                    logger.info(f"Inserting {key} to db")
                    insert_file_to_db(cur, temp_file_path)

                    # Commit the transaction
                    conn.commit()
                    
                    # Upload the file to the processed folder
                    logger.info(f"Uploading {key} to processed folder")
                    move_to_processed_folder(key)

                    # Log the completion of the file processing
                    logger.info(f"Finished processing {key}")
    except Exception as e:
        logger.error(traceback.format_exc())
        raise Exception(f"Error {e} when uploading {key}")
    finally:
        if tunnel:
            tunnel.stop()

    
if __name__ == "__main__":
    upload_recent_tracks_to_db()
