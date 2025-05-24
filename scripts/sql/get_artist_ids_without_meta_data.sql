WITH all_artist_ids AS (
    SELECT DISTINCT
        jsonb_array_elements_text(spotify_track_meta_data_artist_ids) as artist_id
    FROM spotify_track_meta_data
),

artists_with_meta_data AS (
    SELECT DISTINCT
        spotify_artist_meta_data_artist_id as artist_id
    FROM spotify_artist_meta_data
),

artists_with_missing_meta_data AS (
    SELECT
        artist_id
    FROM all_artist_ids
    EXCEPT
    SELECT
        artist_id
    FROM artists_with_meta_data
)

SELECT * FROM artists_with_missing_meta_data
