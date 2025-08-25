import boto3
import csv
from io import StringIO
import os
from datetime import datetime
import spotipy
from spotipy.oauth2 import SpotifyOAuth

OUTPUT_BUCKET_NAME = os.environ["OUTPUT_BUCKET_NAME"]
OUTPUT_PREFIX = os.environ["OUTPUT_PREFIX"]
OUTPUT_KEY = f"{OUTPUT_PREFIX}/recently_played_tracks_{datetime.now().strftime('%Y-%m-%d-%H-%M-%S')}.csv"

def lambda_handler(event, context):
    sp_oauth = SpotifyOAuth(
        client_id=os.environ['CLIENT_ID'],
        client_secret=os.environ['CLIENT_SECRET'],
        redirect_uri=os.environ['REDIRECT_URI'],
        cache_path='/tmp/token_cache.json'
    )

    refresh_token = os.environ['SPOTIFY_REFRESH_TOKEN']
    token_info = sp_oauth.refresh_access_token(refresh_token)
    access_token = token_info['access_token']

    sp = spotipy.Spotify(auth=access_token)
    results = sp.current_user_recently_played(limit=50)

    rows = [
        ["played_at", "track_id", "artist_name", "track_name"]
    ]
    for item in results['items']:
        rows.append([
            item['played_at'],
            item['track']['id'],
            item['track']['artists'][0]['name'],
            item['track']['name'],
        ])

    csv_buffer = StringIO()
    writer = csv.writer(csv_buffer)
    writer.writerows(rows)

    s3 = boto3.client('s3')
    s3.put_object(
        Bucket=OUTPUT_BUCKET_NAME,
        Key=OUTPUT_KEY,
        Body=csv_buffer.getvalue()
    )