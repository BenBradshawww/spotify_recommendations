import logging
import sys
import os

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'upload_scripts'))

from upload_recent_tracks_to_postgres import upload_recent_tracks_to_db
from upload_playlists import upload_playlists
from upload_track_meta_data import upload_track_meta_data
from upload_album_meta_data import upload_album_meta_data
from upload_artist_meta_data import upload_artist_meta_data
# ----------------------------
# Logging
# ----------------------------
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)


# ----------------------------
# Main function
# ----------------------------
def update_db():
    logger.info("Adding recent tracks to database...")
    upload_recent_tracks_to_db()

    logger.info("Adding playlists to database...")
    upload_playlists()

    logger.info("Adding track metadata to database...")
    upload_track_meta_data()

    logger.info("Adding album metadata to database...")
    upload_album_meta_data()

    logger.info("Adding artist metadata to database...")
    upload_artist_meta_data()


if __name__ == "__main__":
    logger.info("Updating db...")
    update_db()
    logger.info("Database updated successfully!")