import os
import logging
import argparse
from datetime import datetime

import spotipy
from spotipy.oauth2 import SpotifyOAuth
from dotenv import load_dotenv

# -----------------
# Load environment variables
# -----------------
load_dotenv()


# -----------------
# Logging
# -----------------
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


# -----------------
# Constants
# -----------------
PLAYLIST_NAME = f"Weekly Recommendations - {datetime.now().strftime('%Y-%m-%d')}"
CSV_FILE_PATH = "./data/recommendations/cosine_similarity_top_25_tracks_2025_05_26.csv"


# -----------------
# Parse arguments
# -----------------
parser = argparse.ArgumentParser()
parser.add_argument("--playlist_name", type=str, default=PLAYLIST_NAME)
parser.add_argument("--csv_file_path", type=str, default=CSV_FILE_PATH)


# -----------------
# Helper functions
# -----------------
def load_track_ids_from_csv(file_path: str) -> list[str]:
    # Load the track IDs from the CSV file
    with open(file_path, 'r') as file:
        next(file) # skip the header line
        rows = file.readlines()
        track_ids = [f"spotify:track:{row.split(',')[0].strip()}" for row in rows]
    return track_ids


def create_playlist(playlist_name: str, csv_file_path: str) -> None:
    # Replace with your actual Spotify API credentials
    sp_oauth = SpotifyOAuth(
        client_id=os.environ['SPOTIFY_CLIENT_ID'],
        client_secret=os.environ['SPOTIFY_CLIENT_SECRET'],
        redirect_uri=os.environ['SPOTIFY_REDIRECT_URI'],
    )

    # Get a refresh token for creating a playlist
    refresh_token = os.environ['SPOTIFY_REFRESH_TOKEN_FOR_CREATING_PLAYLIST']

    # Refresh the access token
    token_info = sp_oauth.refresh_access_token(refresh_token)

    # Use the refreshed access token to create a playlist
    access_token = token_info['access_token']

    # Initialize the Spotify API with the refreshed access token
    sp = spotipy.Spotify(auth=access_token)

    # Get current user ID
    user_id = sp.current_user()["id"]

    # Create a new playlist
    playlist = sp.user_playlist_create(user=user_id, name=playlist_name, public=True, description="")

    # Load the track IDs from the CSV file
    track_ids = load_track_ids_from_csv(csv_file_path)

    # Add the tracks to the playlist
    sp.user_playlist_add_tracks(user=user_id, playlist_id=playlist["id"], tracks=track_ids)

    # Show playlist URL
    logger.info(f"Playlist created: {playlist['external_urls']['spotify']}")


if __name__ == "__main__":
    args = parser.parse_args()
    create_playlist(
        playlist_name=args.playlist_name,
        csv_file_path=args.csv_file_path,
    )