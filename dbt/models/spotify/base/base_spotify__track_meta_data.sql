WITH source AS (
    SELECT
      *
    FROM {{ source('spotify', 'spotify_track_meta_data') }}
),

model AS (
    SELECT
        spotify_track_meta_data_id,
        spotify_track_meta_data_created_at,
        spotify_track_meta_data_updated_at,
        spotify_track_meta_data_track_id,
        spotify_track_meta_data_track_name,
        spotify_track_meta_data_artists,
        spotify_track_meta_data_album,
        spotify_track_meta_data_track_release_date,
        spotify_track_meta_data_track_duration_ms,
        spotify_track_meta_data_track_number,
        spotify_track_meta_data_popularity
    FROM source
)

SELECT * FROM model
