WITH old_tracks AS (
    SELECT 
        spotify_old_tracks_track_id AS spotify_track_id,
        spotify_old_tracks_artist_name AS spotify_artist_name,
        spotify_old_tracks_track_name AS spotify_track_name,
        spotify_old_tracks_album_name AS spotify_album_name,
        spotify_old_tracks_ms_played AS spotify_ms_played,
        spotify_old_tracks_reason_start AS spotify_reason_start,
        spotify_old_tracks_reason_end AS spotify_reason_end,
        spotify_old_tracks_shuffle AS spotify_shuffle,
        spotify_old_tracks_skipped AS spotify_skipped,
        spotify_old_tracks_offline AS spotify_offline,
        spotify_old_tracks_played_at::timestamp AS spotify_track_played_at
    FROM {{ ref('base_spotify__old_tracks') }}
),

last_tracks AS (
    SELECT
        spotify_recent_tracks_track_id AS spotify_track_id,
        spotify_recent_tracks_artist_name AS spotify_artist_name,
        spotify_recent_tracks_track_name AS spotify_track_name,
        NULL AS spotify_album_name,
        CAST(NULL AS INTEGER) AS spotify_ms_played,
        CAST(NULL AS VARCHAR) AS spotify_reason_start,
        CAST(NULL AS VARCHAR) AS spotify_reason_end,
        CAST(NULL AS BOOLEAN) AS spotify_shuffle,
        CAST(NULL AS BOOLEAN) AS spotify_skipped,
        CAST(NULL AS BOOLEAN) AS spotify_offline,
        spotify_recent_tracks_track_played_at::timestamp AS spotify_track_played_at
    FROM {{ ref('base_spotify__recent_tracks')}}
),

all_tracks AS (
    SELECT * FROM old_tracks
    UNION
    SELECT * FROM last_tracks
)

SELECT * FROM all_tracks