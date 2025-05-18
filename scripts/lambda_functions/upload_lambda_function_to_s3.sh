#!/bin/bash

# Clean old bu


mkdir lambda_function

cd lambda_function

cp ../scripts/lambda_function.py .

pip install spotipy -t .

zip -r lambda_function.zip .

aws s3 cp lambda_function.zip s3://ben-spotify/lambda_function.zip

cd ..

rm -rf lambda_function
