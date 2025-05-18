WITH recent_tracks AS (
    SELECT DISTINCT
        spotify_recent_tracks_track_id AS spotify_track_id 
    FROM spotify_recent_tracks
),

old_tracks AS (
    SELECT DISTINCT
        spotify_old_tracks_track_id AS spotify_track_id
    FROM spotify_old_tracks
),

playlists AS (
    SELECT DISTINCT 
        spotify_playlists_track_id AS spotify_track_id
    FROM spotify_playlists
),

all_tracks AS (
    SELECT * FROM recent_tracks
    UNION
    SELECT * FROM old_tracks
    UNION
    SELECT * FROM playlists
),

meta_data_tracks AS (
    SELECT spotify_track_meta_data_track_id 
    FROM spotify_track_meta_data
),

tracks_without_meta_data AS (
    SELECT * FROM all_tracks
    EXCEPT
    SELECT * FROM meta_data_tracks
)

SELECT DISTINCT spotify_recent_tracks_track_id 
FROM tracks_without_meta_data