WITH all_heard_tracks AS (
    SELECT DISTINCT
        spotify_track_id AS spotify_track_id
    FROM {{ ref('int_spotify__all_heard_tracks') }}
),

playlists_tracks AS (
    SELECT DISTINCT
        spotify_playlists_track_id AS spotify_track_id,
        spotify_playlists_track_name AS spotify_track_name,
        spotify_playlists_track_artists AS spotify_artists,
        spotify_playlists_track_album_name AS spotify_album_name,
        spotify_playlists_track_track_number AS spotify_track_number,
        spotify_playlists_track_duration_ms AS spotify_track_duration_ms,
        spotify_playlists_track_album_release_date AS spotify_album_release_date,
        spotify_playlists_track_popularity AS spotify_track_popularity
    FROM {{ ref('base_spotify__playlists') }}
),

not_heard_tracks AS (
    SELECT
        pt.spotify_track_id,
        pt.spotify_track_name,
        pt.spotify_artists,
        pt.spotify_album_name,
        pt.spotify_track_number,
        pt.spotify_track_duration_ms,
        pt.spotify_album_release_date,
        pt.spotify_track_popularity
    FROM playlists_tracks AS pt
    LEFT JOIN all_heard_tracks AS at
        ON pt.spotify_track_id = at.spotify_track_id
    WHERE at.spotify_track_id IS NULL
)

SELECT * FROM not_heard_tracks