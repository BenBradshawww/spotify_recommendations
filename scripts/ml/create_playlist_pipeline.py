import logging
import argparse
from datetime import datetime

from create_playlist import create_playlist
from cosine_similarity import cosine_similarity


# -----------------
# Logging
# -----------------
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


# -----------------
# Argument Parsing
# -----------------
def parse_arguments() -> argparse.Namespace:
    default_playlist_name = f"Weekly Recommendations - {datetime.now().strftime('%Y-%m-%d')}"
    default_csv_path = "./data/recommendations/cosine_similarity_top_25_tracks_2025_05_26.csv"

    parser = argparse.ArgumentParser(description="Create a playlist from a CSV file")
    parser.add_argument("--playlist_name", type=str, default=default_playlist_name, help="Name of the playlist")
    parser.add_argument("--csv_file_path", type=str, default=default_csv_path, help="Path to the CSV file")
    parser.add_argument("--n_tracks", type=int, default=25, help="Number of tracks to recommend")

    return parser.parse_args()


# -----------------
# Main logic
# -----------------
def create_weekly_recommendations_playlist(playlist_name: str, csv_file_path: str, n_tracks: int) -> None:
    logger.info(f"Running cosine similarity for top {n_tracks} tracks...")
    cosine_similarity(output_file_path=csv_file_path, num_tracks=n_tracks)

    logger.info(f"Creating playlist: {playlist_name}")
    create_playlist(playlist_name=playlist_name, csv_file_path=csv_file_path)


# -----------------
# Entrypoint
# -----------------
if __name__ == "__main__":
    args = parse_arguments()
    logger.info("Starting create playlist script...")

    create_weekly_recommendations_playlist(
        playlist_name=args.playlist_name,
        csv_file_path=args.csv_file_path,
        n_tracks=args.n_tracks
    )

    logger.info("Create playlist script completed successfully!")