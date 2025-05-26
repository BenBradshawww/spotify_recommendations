import logging
from datetime import datetime

from utilities import create_playlist
from cosine_similarity import cosine_similarity

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
N_TRACKS = 25


# -----------------
# Main function
# -----------------
def create_weekly_recommendations_playlist() -> None:

    logger.info("Starting cosine similarity script...")
    cosine_similarity(output_file_path=CSV_FILE_PATH, num_tracks=N_TRACKS)

    logger.info("Creating playlist...")
    create_playlist(playlist_name=PLAYLIST_NAME, csv_file_path=CSV_FILE_PATH)


if __name__ == "__main__":
    logger.info("Starting create playlist script...")
    create_weekly_recommendations_playlist()
    logger.info("Create playlist script completed successfully!")