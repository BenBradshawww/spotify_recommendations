WITH source AS (
    SELECT
      *
    FROM {{ source('spotify', 'spotify_recent_tracks') }}
),

model AS (
    SELECT
        spotify_recent_tracks_track_id,
        spotify_recent_tracks_created_at,
        spotify_recent_tracks_updated_at,
        spotify_recent_tracks_track_played_at,
        spotify_recent_tracks_track_name,
        spotify_recent_tracks_artist_name
    FROM source
)

SELECT * FROM model
