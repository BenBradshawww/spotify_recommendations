WITH all_heard_tracks AS (
    SELECT DISTINCT
        spotify_track_id,
        spotify_track_name
    FROM {{ ref('int_spotify__all_heard_tracks') }}
),

not_heard_tracks AS (
    SELECT
        spotify_track_id,
        spotify_track_name
    FROM {{ ref('int_spotify__not_heard_tracks') }}     
)

SELECT * FROM all_heard_tracks
UNION
SELECT * FROM not_heard_tracks
