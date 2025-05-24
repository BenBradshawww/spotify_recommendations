WITH source AS (
    SELECT
      *
    FROM {{ source('spotify', 'spotify_album_meta_data') }}
),

model AS (
    SELECT
        spotify_album_meta_data_id,
        spotify_album_meta_data_created_at,
        spotify_album_meta_data_updated_at,
        spotify_album_meta_data_album_id,
        spotify_album_meta_data_album_name,
        spotify_album_meta_data_album_release_date,
        spotify_album_meta_data_album_total_tracks,
        spotify_album_meta_data_album_type,
        spotify_album_meta_data_album_artist_ids,
        spotify_album_meta_data_album_artist_names,
        spotify_album_meta_data_album_label,
        spotify_album_meta_data_album_popularity
    FROM source
)

SELECT * FROM model
