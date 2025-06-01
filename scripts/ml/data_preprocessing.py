import logging

import numpy as np
import pandas as pd

from sklearn.preprocessing import MinMaxScaler
from scipy.stats import rankdata

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

# -----------------
# Data Preprocessing Functions
# -----------------
def one_hot_encode_columns(df: pd.DataFrame, columns: list[str], drop_missing: bool = False) -> pd.DataFrame:
	df = df.copy()  # Create copy to avoid modifying original
	for col in columns:
		logger.info(f"One-hot encoding {col}...")
		df[col] = df[col].astype(str)
		dummies = pd.get_dummies(df[col], prefix=col, dtype=pd.SparseDtype("int", 0))
		df = pd.concat([df, dummies], axis=1)
	return df


def log_1p_minmax_scale_columns(df: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
	df = df.copy()  # Create copy to avoid modifying original
	scaler = MinMaxScaler()  # Create single scaler instance outside the loop
	
	for col in columns:
		logger.info(f"Log transforming and min-max scaling {col}...")
		df[col] = np.log1p(df[col])
		df[col] = scaler.fit_transform(df[col].values.reshape(-1, 1)).ravel()
		scaler = MinMaxScaler()
	
	return df


def scale_by_100_columns(df: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
	df = df.copy()  # Create copy to avoid modifying original
	for col in columns:
		logger.info(f"Scaling {col} by 100...")
		df[col] = df[col] / 100
	return df


def rank_transform_columns(df: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
	df = df.copy()  # Create copy to avoid modifying original
	for col in columns:
		logger.info(f"Rank transforming {col}...")
		df[col] = rankdata(df[col], method="average") 
		df[col] = MinMaxScaler().fit_transform(df[col].values.reshape(-1, 1)).ravel()
	return df
