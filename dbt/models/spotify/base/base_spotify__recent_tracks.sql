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
        CASE
          WHEN spotify_recent_tracks_track_name = 'Unknown Track'
            THEN NULL
          ELSE spotify_recent_tracks_track_name
        END,
        CASE
          WHEN spotify_recent_tracks_artist_name = 'Unknown Artist'
            THEN NULL
          ELSE spotify_recent_tracks_artist_name
        END
    FROM source
)

SELECT * FROM model
