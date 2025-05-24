WITH all_album_ids AS (
    SELECT DISTINCT
        spotify_track_meta_data_album_id as album_id
    FROM spotify_track_meta_data
),

album_ids_with_meta_data AS (
    SELECT DISTINCT
        spotify_album_meta_data_album_id as album_id
    FROM spotify_album_meta_data
),

album_ids_with_missing_meta_data AS (
    SELECT
        album_id
    FROM all_album_ids
    EXCEPT
    SELECT
        album_id
    FROM album_ids_with_meta_data
)

SELECT * FROM album_ids_with_missing_meta_data