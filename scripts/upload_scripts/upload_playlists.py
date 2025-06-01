import logging
import os
import json
import traceback
import spotipy
from datetime import datetime
from dotenv import load_dotenv
from utilities import create_spotify_client, upload_rows_to_postgres, normalize_date

# ----------------------------
# Load environment variables
# ----------------------------
load_dotenv()

# ----------------------------
# Constants
# ----------------------------
SSH_KEY_PATH = os.path.expanduser("~/.ssh/personal.pem")
SQL_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "sql", "insert_spotify_playlists.sql")

# ----------------------------
# Logging
# ----------------------------
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

# ----------------------------
# Playlist URLs
# ----------------------------
playlist_urls = [
    ("Radar","https://open.spotify.com/user/31bucyspxkpruxjrkz65o6snoc7i", "Weekly Radar", "https://open.spotify.com/playlist/1iLl45TYUW0ZbuGj913mQs"),
    ("Jah Talks Music","https://open.spotify.com/user/fgy1vuygflfwapaeaba6wbxtf", "We gon be alright", "https://open.spotify.com/playlist/5moYNM7dHAX6Rjv1Tb96oO"), 
    ("Jah Talks Music","https://open.spotify.com/user/fgy1vuygflfwapaeaba6wbxtf", "The Weekly Rotation", "https://open.spotify.com/playlist/2X6kTAPPf4hxJQ2shs68lK"), 
    ("Jah Talks Music","https://open.spotify.com/user/fgy1vuygflfwapaeaba6wbxtf", "New Music Friday Full", "https://open.spotify.com/playlist/6yY1ZjBPj4mQKw9i6OAet5"), 
    ("Jah Talks Music","https://open.spotify.com/user/fgy1vuygflfwapaeaba6wbxtf", "New Music Friday", "https://open.spotify.com/playlist/0W77yO15nQw823lDjAXM48"), 
    ("hiphopadellic", "https://open.spotify.com/user/314ibtizksfokh3ryombaz7lfpdq", "New Music Friday UK", "https://open.spotify.com/playlist/2nm70NhYHpOSVQUH6EuQ29"), 
    ("Madbrad200","https://open.spotify.com/user/madbrad200","2025 Grime", "https://open.spotify.com/playlist/6nBFllAlmmbJ5VQpFMD7uF"),
    ("Alex Wilson","https://open.spotify.com/user/alexanderjojames", "relax g", "https://open.spotify.com/playlist/4Kc5k2OZpEOzyAqOHPR4JH"),
    ("Alex Wilson","https://open.spotify.com/user/alexanderjojames", "A&H non-rap <3", "https://open.spotify.com/playlist/6L5SC1mk7kR88CIGy2iA2e"),
    ("christainfenton","https://open.spotify.com/user/christianfenton", "issa carnival", "https://open.spotify.com/playlist/45r1WJILWU4WPnhxWMwVTA"),
    ("Alex Wilson","https://open.spotify.com/user/alexanderjojames", "A&H", "https://open.spotify.com/playlist/6JpkqnhrQKa2F95d5bAPHf"),
    ("Alex Wilson","https://open.spotify.com/user/alexanderjojames", "Bruck it", "https://open.spotify.com/playlist/5xq3jdbYbcN52r9euTBrTv"),
    ("Alex Wilson","https://open.spotify.com/user/alexanderjojames", "SYM", "https://open.spotify.com/playlist/1ZgoWsJLaJFuKrigF7TuB4"),
    ("Alex Wilson","https://open.spotify.com/user/alexanderjojames", "D R Us", "https://open.spotify.com/playlist/0btKiaxonh1bp80qEribRQ"),
    ("Alex Wilson","https://open.spotify.com/user/alexanderjojames", "Driving the honda click", "https://open.spotify.com/playlist/0hWTwiSGZXWzsexAy49QUa"),
    ("christainfenton","https://open.spotify.com/user/christianfenton", "rice and peas", "https://open.spotify.com/playlist/3fP77laBvLOvRIpSgenuqu"),
    ("THEOCIDE STUDIOS", "https://open.spotify.com/user/teocida","New AFROBEATS 2025", "https://open.spotify.com/playlist/71fVPAEmw6drbQRZnYOD4O"),
    ("selected.","https://open.spotify.com/user/31bkjv4frr3axzpq3yp7ekyn4vcy", "RELEASE RADAR", "https://open.spotify.com/playlist/4uSfCxo6xS06B5G1yoLtK0"),
    ("MINT WRLD", "https://open.spotify.com/user/zg2ozq5hq8bykvgeflllw1ntx","Hits Radar New Songs", "https://open.spotify.com/playlist/09SrU7fok2McDpyhn4wVJa"),
    ("HipHopNumbers", "https://open.spotify.com/user/1231119230","HipHopNumbers Weekly", "https://open.spotify.com/playlist/6UIg0POgmC4ycyYKEaLure"),
    ("Burnt Log", "https://open.spotify.com/user/flandersdanders","Neigh! | New Indie Finds", "https://open.spotify.com/playlist/6FoDv7evUgwF5vFyB8hofQ"),
    ("Somewhere Soul", "https://open.spotify.com/user/ptf68083wtq6b14v90r1a37fp", "New Music Friday", "https://open.spotify.com/playlist/0tB0SEV6OkYhtD7X9nFAgr"),
    ("THEOCIDE STUDIOS", "https://open.spotify.com/user/teocida", "New REGGAE 2025", "https://open.spotify.com/playlist/42vTpatIcSNFkDOol0GmDR"),
    ("Vetle Veierod","https://open.spotify.com/user/vetlevei","New Music 2025 - Handpicked Release Radar", "https://open.spotify.com/playlist/0sVOopWlxQmgqUWaIMtT1s"),
    ("AFRO4LYFE", "https://open.spotify.com/user/31o2wnibgqooxblvrg7dosnajfxm", "AFROBETATS MIX 2025/2026", "https://open.spotify.com/playlist/3ULVfUUAQkzd20NnMk9SCf"),
    ("Island Ting", "https://open.spotify.com/user/o7wkllyou6sctpe2e7jkvwld9","New Afroswing 2025 Official","https://open.spotify.com/playlist/4rymECAcgXuvyi27ehc0Ps"),
    ("Afrikan Radar", "https://open.spotify.com/user/31yn33ajrpj5uzi6bc7u66v2w424","Best Of Afrobeats", "https://open.spotify.com/playlist/0DmcmP6aWaCVAHzl0B5YOW"),
    ("Afrikan Radar", "https://open.spotify.com/user/31yn33ajrpj5uzi6bc7u66v2w424","Afrobeats Bangers", "https://open.spotify.com/playlist/1trJD4VpeDFh5js6ZheGDM"),
    ("davina1407", "https://open.spotify.com/user/davina1407","Afrochill Best Chilled Afrobeats - Summer 2025", "https://open.spotify.com/playlist/1ewb2XyvHJa54RI2iBrVmr"),
    ("HipHopNumbers", "https://open.spotify.com/user/1231119230" , "HipHopNumbers Weekly", "https://open.spotify.com/playlist/6UIg0POgmC4ycyYKEaLure"),
    ("New Tunes Inc", "https://open.spotify.com/user/31psdh4dvsegpa34lza35kvvjxzm", "New Hip Hop", "https://open.spotify.com/playlist/3dIL3zfPPmSLq7P90brGmJ"),
    ("New Tunes Inc", "https://open.spotify.com/user/31psdh4dvsegpa34lza35kvvjxzm", "New Trending", "https://open.spotify.com/playlist/2LWvtd1mJOiwzQys88U20P"),
]

# ----------------------------
# Helper Functions
# ----------------------------
def get_playlist_rows(sp: spotipy.Spotify) -> list[tuple]:
    time = datetime.now()
    date = time.strftime("%Y-%m-%d")
    rows = []
    for (user_name, user_url, playlist_name, playlist_url) in playlist_urls:

        user_id = user_url.split('/')[-1]
        playlist_id = playlist_url.split('/')[-1]

        try:
            logging.info(f"Processing playlist: {playlist_name}")

            playlist_id = playlist_url.split("/")[-1]
            results = sp.playlist_items(playlist_id, market="US")
            
            for item in results["items"]:
                if item is not None and item.get("track") is not None:
                    track = item["track"]
                    artists = track.get("artists", [])
                    row = tuple([
                        playlist_id,
                        playlist_name,
                        user_id,
                        user_name,
                        normalize_date(date),
                        item.get("added_at", None),
                        item.get("added_by", {}).get("id", None),
                        track.get("id", None),
                        track.get("name", None),
                        json.dumps([artist["name"] for artist in artists if artist is not None]),
                        json.dumps([artist["id"] for artist in artists if artist is not None]),
                        track.get("album", {}).get("name", None),
                        track.get("track_number", None),
                        track.get("duration_ms", None),
                        normalize_date(track.get("album", {}).get("release_date", None)),
                        track.get("popularity", None),
                    ])
                    rows.append(row)
        except spotipy.exceptions.SpotifyException as e:
            logger.error(f"Spotify API Error: {e}")
            logger.error(traceback.format_exc())
        except Exception as e:
            logger.error(f"General Error: {e}")
            logger.error(traceback.format_exc())
    
    return rows



# ----------------------------
# Main function
# ----------------------------
def upload_playlists():
    global sp
    sp = create_spotify_client()

    # Get rows where each row is a track in a playlist
    rows = get_playlist_rows(sp)

    # Upload the rows to the database
    upload_rows_to_postgres(rows, SQL_PATH)
    

if __name__ == "__main__":
    upload_playlists()