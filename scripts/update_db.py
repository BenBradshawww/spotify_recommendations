import sys
import os
import logging
from logging.handlers import RotatingFileHandler


# ----------------------------
# Logging
# ----------------------------
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)

project_dir = os.path.dirname(os.path.dirname(__file__))
logs_path = os.path.join(project_dir, "logs/update_db_logs")
file_handler = RotatingFileHandler(
    logs_path,
    mode='a',
    maxBytes=5 * 1024 * 1024,
    backupCount=5,
)
file_handler.setLevel(logging.DEBUG)

formatter = logging.Formatter('%(asctime)s - %(name)s [%(levelname)s] %(message)s')
console_handler.setFormatter(formatter)
file_handler.setFormatter(formatter)

logger.addHandler(console_handler)
logger.addHandler(file_handler)


# ----------------------------
# Import functions
# ----------------------------
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'upload_scripts'))

from upload_recent_tracks_to_postgres import upload_recent_tracks_to_db
from upload_playlists import upload_playlists
from upload_track_meta_data import upload_track_meta_data
from upload_album_meta_data import upload_album_meta_data
from upload_artist_meta_data import upload_artist_meta_data


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
