WITH source AS (
    SELECT
      *
    FROM {{ source('spotify', 'spotify_artist_meta_data') }}
),

model AS (
    SELECT
        spotify_artist_meta_data_id,
        spotify_artist_meta_data_created_at,
        spotify_artist_meta_data_updated_at,
        spotify_artist_meta_data_artist_id,
        spotify_artist_meta_data_artist_name,
        COALESCE(spotify_artist_meta_data_artist_followers_total, 0) AS spotify_artist_meta_data_artist_followers_total,
        COALESCE(spotify_artist_meta_data_artist_popularity, 0) AS spotify_artist_meta_data_artist_popularity,
        spotify_artist_meta_data_artist_genres AS spotify_artist_meta_data_artist_genres
    FROM source
)

SELECT * FROM model
