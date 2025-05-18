WITH all_heard_tracks AS (
    SELECT DISTINCT
        spotify_track_id AS spotify_track_id
    FROM int_spotify__all_tracks
),

playlists_tracks AS (
    SELECT DISTINCT
        spotify_playlists_track_id AS spotify_track_id
    FROM spotify_playlists
),

not_heard_tracks AS (
    SELECT
        spotify_track_id
    FROM playlists_tracks
    EXCEPT
    SELECT
        spotify_track_id
    FROM all_heard_tracks
)

SELECT * FROM not_heard_tracks