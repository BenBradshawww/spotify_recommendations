import os
import traceback
import logging 
from datetime import datetime

import boto3
import psycopg2
import spotipy
import dotenv
from spotipy.oauth2 import SpotifyClientCredentials
from sshtunnel import SSHTunnelForwarder
from psycopg2.extras import execute_values


# ----------------------------
# Load environment variables
# ----------------------------
dotenv.load_dotenv()


# ----------------------------
# Logging
# ----------------------------
logger = logging.getLogger(__name__)


# ----------------------------
# Create clients
# ----------------------------
ec2 = boto3.client('ec2')

# ----------------------------
# Helper functions
# ----------------------------
def get_public_ip() -> str:
    try:
        response = ec2.describe_instances(InstanceIds=[os.environ.get("EC2_INSTANCE_ID")])
        if not response:
            raise Exception("No response from EC2 instance. Check instance or networking config.")
        public_ip = None
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                public_ip = instance.get('PublicIpAddress')
                return public_ip
        
        if not public_ip:
            raise Exception("No public IP found. Check instance or networking config.")
        
    except Exception as e:
        logger.error(traceback.format_exc())
        raise Exception(f"Error: {e}")
    

def create_spotify_client():
    sp = spotipy.Spotify(client_credentials_manager=SpotifyClientCredentials(
        client_id=os.getenv("SPOTIPY_CLIENT_ID"),
        client_secret=os.getenv("SPOTIPY_CLIENT_SECRET")
    ))
    return sp


def upload_rows_to_postgres(rows: list[tuple[str]], sql_path: str) -> None:

    sql = open(sql_path, "r").read()

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
                password=os.environ.get("POSTGRES_PASSWORD"),
                host='localhost',
                port=tunnel.local_bind_port
            )

            with conn.cursor() as cur:
                execute_values(cur, sql, rows)

            conn.commit()
            conn.close()
    except Exception as e:
        logger.error(traceback.format_exc())
        raise e
    

def normalize_date(date_str):
    """
    Normalize Spotify's release_date string (which may be in YYYY, YYYY-MM, or YYYY-MM-DD format)
    into a full YYYY-MM-DD string. Returns None for invalid input.
    """
    if not date_str or not isinstance(date_str, str):
        return None

    try:
        if len(date_str) == 4:  # YYYY
            normalized = f"{date_str}-01-01"
        elif len(date_str) == 7:  # YYYY-MM
            normalized = f"{date_str}-01"
        elif len(date_str) == 10:  # YYYY-MM-DD
            normalized = date_str
        else:
            return None  # Invalid format
        
        # Check if it's a valid date
        return datetime.strptime(normalized, "%Y-%m-%d").date()
    except ValueError:
        return None