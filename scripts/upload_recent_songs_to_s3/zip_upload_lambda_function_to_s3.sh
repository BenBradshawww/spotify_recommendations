#!/usr/bin/env bash
set -euo pipefail

# Run from the repo root
ART_DIR="artifacts"
PY_FILE="lambda_function_upload_recent_songs_to_s3.py"
ZIP_NAME="lambda_function_upload_recent_songs_to_s3.zip"

mkdir -p temp_dir
cd temp_dir

# bring in your lambda file to the artifacts root
cp ../scripts/upload_recent_songs_to_s3/"$PY_FILE" .

# vendor deps into the zip root
python3 -m pip install --upgrade pip
python3 -m pip install spotipy -t .

# create zip from the *contents* of artifacts (rooting files at zip top-level)
zip -r "$ZIP_NAME" .

# Copy zip to artifacts directory
cp $ZIP_NAME ../"$ART_DIR"/

cd ..

rm -r temp_dir

echo "Built $ART_DIR/$ZIP_NAME"