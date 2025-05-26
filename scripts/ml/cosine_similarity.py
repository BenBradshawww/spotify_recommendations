import os  
import sys 
import logging
import argparse
from datetime import datetime

import pandas as pd
import numpy as np
from sqlalchemy import create_engine
from data_preprocessing import one_hot_encode_columns, log_1p_minmax_scale_columns, scale_by_100_columns, rank_transform_columns
from sklearn.metrics.pairwise import cosine_similarity as sklearn_cosine_similarity
from sklearn.decomposition import TruncatedSVD
from scipy.sparse import csr_matrix
from dotenv import load_dotenv

# -----------------
# Logging
# -----------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)


# -----------------
# Load environment variables
# -----------------
load_dotenv()


# -----------------
# Constants
# -----------------
# I've removed "spotify_artist_popularity" for now
COLUMNS_TO_KEEP = [
    "spotify_track_id",
    "spotify_track_heard",
    "spotify_artist_id",
    "spotify_track_release_date",
    "spotify_track_duration_ms",
    "spotify_artist_followers_total",
    "spotify_artist_genre",
    "three_month_artist_listen_count",
    "one_year_artist_listen_count",
    "lifetime_artist_listen_count",
    "three_month_artist_listen_prop",
    "one_year_artist_listen_prop",
    "three_month_genre_listen_count",
    "one_year_genre_listen_count",
    "lifetime_genre_listen_count",
    "three_month_genre_listen_prop",
    "one_year_genre_listen_prop",
]

COLUMNS_FOR_ONE_HOT_ENCODING = [
    "spotify_artist_genre",
    "spotify_artist_id",
]

COLUMNS_FOR_LOG_1P_MINMAX_SCALER = [
    "spotify_track_duration_ms",
	"three_month_artist_listen_count",
	"one_year_artist_listen_count",
	"three_month_genre_listen_count",
	"one_year_genre_listen_count",
	"lifetime_genre_listen_count",
	"spotify_artist_followers_total",
]

COLUMNS_FOR_DIVIDE_BY_100 = [
	#"spotify_artist_popularity",
]

COLUMNS_FOR_RANK_TRANSFORM = [
    "lifetime_artist_listen_count"
]


# -----------------
# Helper functions
# -----------------
def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--num_tracks", type=int, default=25, help="Number of tracks to recommend")
    parser.add_argument("--output_file_path", type=str, default=f"./data/recommendations/cosine_similarity_top_{datetime.now().strftime('%Y_%m_%d')}.csv", help="Path to save the output file")
    args = parser.parse_args()
    return args


def load_data() -> pd.DataFrame:
    # Connect to the database
    engine = create_engine(
        f"postgresql+psycopg2://postgres:{os.getenv('POSTGRES_PASSWORD')}@localhost:5433/spotify"
    )

    # Read the data from the database
    df = pd.read_sql(f"SELECT {', '.join(COLUMNS_TO_KEEP)} FROM mart_spotify__merged_tracks", con=engine)
    return df


def fill_nas(df: pd.DataFrame) -> pd.DataFrame:
    output_columns = []
    for col in df.columns:
        output_columns.append(col)
        if df[col].isna().sum() > 0:
            logger.warning(f"{col} has {df[col].isna().sum()} missing values.")
            if df[col].dtype == "object":
                logger.info(f"Filling the missing values with 'missing' for {col}...")
                df[col] = df[col].fillna("missing")
            elif df[col].dtype == "float64":
                logger.info(f"Filling the missing values with 0.0 for {col}...")
                df[col] = df[col].fillna(0.)
            elif df[col].dtype == "int64":
                logger.info(f"Filling the missing values with 0 for {col}...")
                df[col] = df[col].fillna(0)
            
    return df


def preprocess_data(df: pd.DataFrame) -> pd.DataFrame:

    # Log transforming and min-max scaling the columns
    logger.info(f"Log transforming and min-max scaling the columns: {COLUMNS_FOR_LOG_1P_MINMAX_SCALER}...")
    df = log_1p_minmax_scale_columns(df, COLUMNS_FOR_LOG_1P_MINMAX_SCALER)

    # Scaling the columns by 100
    logger.info(f"Scaling the columns by 100: {COLUMNS_FOR_DIVIDE_BY_100}...")
    df = scale_by_100_columns(df, COLUMNS_FOR_DIVIDE_BY_100)

    # Rank transforming the columns
    logger.info(f"Rank transforming the columns: {COLUMNS_FOR_RANK_TRANSFORM}...")
    df = rank_transform_columns(df, COLUMNS_FOR_RANK_TRANSFORM)

    # Drop the columns that are not needed
    logger.info(f"Dropping the columns that are not needed...")
    df = df.drop(columns=["spotify_track_release_date", "spotify_track_heard"])

    # One-hot encoding the columns
    logger.info(f"One-hot encoding the columns: {COLUMNS_FOR_ONE_HOT_ENCODING}...")
    df = one_hot_encode_columns(df, COLUMNS_FOR_ONE_HOT_ENCODING)

    return df


def reduce_dimensionality(df: pd.DataFrame, n_components: int = 100, target_variance: float = 0.95) -> pd.DataFrame:
    logger.info(f"Reducing dimensionality of {df.shape[1]} features using TruncatedSVD...")

    X_sparse = csr_matrix(df.values)  
    svd = TruncatedSVD(n_components=n_components, random_state=42)
    reduced_array = svd.fit_transform(X_sparse)

    cumulative_variance = np.cumsum(svd.explained_variance_ratio_)
    logger.info(f"Cumulative variance explained by first {n_components} components: {cumulative_variance[-1]:.4f}")

    # Determine the number of components needed to meet the target variance
    if cumulative_variance[-1] >= target_variance:
        k = np.argmax(cumulative_variance >= target_variance) + 1
        if k < n_components:
            reduced_array = reduced_array[:, :k]
            logger.info(f"Truncating to {k} components to reach ~{target_variance*100:.1f}% explained variance")
    else:
        k = n_components
        logger.warning(f"Target variance of {target_variance:.2f} not reached — only {cumulative_variance[-1]:.4f} explained with {n_components} components")

    return pd.DataFrame(reduced_array, index=df.index)


def get_heard_and_not_heard_indexes(df: pd.DataFrame) -> tuple[pd.Index, pd.Index]:
    # Create a copy of the dataframe
    df = df.copy()

    # Convert dates and filter recent tracks
    df["spotify_track_release_date"] = pd.to_datetime(
        df["spotify_track_release_date"],
        errors='coerce',
        format="mixed",
        infer_datetime_format=True,
    )

    # Get the new and old tracks
    new_tracks = df[df["spotify_track_release_date"] > pd.Timestamp.now() - pd.Timedelta(days=7)]
    old_tracks = df[df["spotify_track_release_date"] <= pd.Timestamp.now() - pd.Timedelta(days=7)]

    # Get the indexes of the old heard tracks
    old_heard_tracks = old_tracks[old_tracks["spotify_track_heard"]]
    
    # Get the indexes of the heard and not heard tracks
    old_tracks_indexes = old_heard_tracks.index.tolist()
    new_tracks_indexes = new_tracks.index.tolist()

    return old_tracks_indexes, new_tracks_indexes


def get_cosine_similarity(heard_df: pd.DataFrame, not_heard_df: pd.DataFrame) -> pd.DataFrame:
    # Get the cosine similarity between the heard and not heard tracks
    heard_features = heard_df.select_dtypes(include=[np.number])
    not_heard_features = not_heard_df.select_dtypes(include=[np.number])

    similarity_matrix = sklearn_cosine_similarity(heard_features.values, not_heard_features.values)

    return pd.DataFrame(
        similarity_matrix,
        index=heard_df.index,
        columns=not_heard_df.index
    )


def get_top_tracks(df: pd.DataFrame, n: int) -> pd.Series:
    # For each not-heard track (column), get the highest similarity to any heard track
    max_similarity = df.max(axis=0)  # axis=0: across rows (heard tracks)

    # Collapse duplicates: for each unique track_id, take the highest similarity
    max_similarity = max_similarity.groupby(level=0).max()

    # Pick the top N unique tracks
    return max_similarity.nlargest(n)


# -----------------
# Main function
# -----------------
def cosine_similarity(output_file_path: str, num_tracks: int) -> None:
    # Load the data
    logger.info("Loading the data...")
    df = load_data()

    # Set spotify_track_id as index
    logger.info("Setting spotify_track_id as index...")
    df = df.set_index('spotify_track_id')

    # Get the indexes of the heard and not heard tracks 
    logger.info("Getting the indexes of the heard and not heard tracks...")
    heard_indexes, not_heard_indexes = get_heard_and_not_heard_indexes(df)

    # Fill the missing values
    logger.info("Filling the missing values...")
    df = fill_nas(df)

    # Preprocess the data
    logger.info("Preprocessing the data...")
    df = preprocess_data(df)
    logger.info(f"Preprocessed data shape: {df.shape}")

    # Reduce dimensionality
    logger.info("Reducing dimensionality...")
    df = reduce_dimensionality(df)
    logger.info(f"Reduced data shape: {df.shape}")

    # Split the dataframe into heard and not heard tracks
    logger.info("Splitting the dataframe into heard and not heard tracks...")
    heard_df = df.loc[heard_indexes]
    not_heard_df = df.loc[not_heard_indexes]
    logger.info(f"Found {len(not_heard_df)} tracks that have released in last week")

    # Get the cosine similarity between the heard and not heard tracks
    logger.info("Generating the cosine similarity matrix...")
    cosine_similarity = get_cosine_similarity(heard_df, not_heard_df)

    # Get the top n tracks with the highest cosine similarity
    logger.info(f"Getting the top {num_tracks} tracks with the highest cosine similarity...")
    top_n_tracks = get_top_tracks(cosine_similarity, num_tracks)

    # Save the top n tracks to a csv file
    logger.info(f"Saving the top {num_tracks} tracks to a csv file...")
    top_n_tracks.to_csv(output_file_path, index=True)
    logger.info(f"Top {num_tracks} tracks saved to {output_file_path}")

if __name__ == "__main__":
    args = parse_arguments()
    logger.info("Starting the cosine similarity script...")
    cosine_similarity(output_file_path=args.output_file_path, num_tracks=args.num_tracks)
    logger.info("Cosine similarity script completed successfully!")
