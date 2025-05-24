WITH tracks AS (
    SELECT DISTINCT
        spotify_track_id,
        spotify_track_name,
        spotify_track_heard
    FROM {{ ref('int_spotify__all_tracks') }}
),

heard_tracks AS (
    SELECT * FROM tracks
    WHERE spotify_track_heard = TRUE
),

not_heard_tracks AS (
    SELECT * FROM tracks
    WHERE spotify_track_heard = FALSE
),

track_meta_data AS (
    SELECT DISTINCT
        spotify_track_meta_data_track_id,
        spotify_track_meta_data_album_id,
        spotify_track_meta_data_album_name,
        jsonb_array_elements_text(spotify_track_meta_data_artist_ids) AS spotify_track_meta_data_artist_id,
        jsonb_array_elements_text(spotify_track_meta_data_artist_names) AS spotify_track_meta_data_artist_name,
        spotify_track_meta_data_track_release_date,
        spotify_track_meta_data_track_duration_ms,
        spotify_track_meta_data_track_number,
        spotify_track_meta_data_popularity
    FROM {{ ref('base_spotify__track_meta_data') }}
),

artists AS (
    SELECT DISTINCT
        spotify_artist_meta_data_artist_id,
        spotify_artist_meta_data_artist_name,
        spotify_artist_meta_data_artist_followers_total,
        spotify_artist_meta_data_artist_popularity,
        spotify_artist_meta_data_artist_genres,
        jsonb_array_elements_text(spotify_artist_meta_data_artist_genres) AS spotify_artist_genre
    FROM {{ ref('base_spotify__artist_meta_data') }}
),

albums AS (
    SELECT DISTINCT
        spotify_album_meta_data_album_id,
        spotify_album_meta_data_album_name,
        spotify_album_meta_data_album_release_date,
        spotify_album_meta_data_album_total_tracks,
        spotify_album_meta_data_album_type,
        spotify_album_meta_data_album_artist_ids,
        spotify_album_meta_data_album_artist_names,
        spotify_album_meta_data_album_label,
        spotify_album_meta_data_album_popularity
    FROM {{ ref('base_spotify__album_meta_data') }}
),

full_table AS (
    SELECT
        tracks.spotify_track_id,
        tracks.spotify_track_name,
        tracks.spotify_track_heard,
        track_meta_data.spotify_track_meta_data_album_id AS spotify_album_id,
        track_meta_data.spotify_track_meta_data_album_name AS spotify_album_name,
        track_meta_data.spotify_track_meta_data_artist_id AS spotify_artist_id,
        track_meta_data.spotify_track_meta_data_artist_name AS spotify_artist_name,
        track_meta_data.spotify_track_meta_data_track_release_date AS spotify_track_release_date,
        track_meta_data.spotify_track_meta_data_track_duration_ms AS spotify_track_duration_ms,
        track_meta_data.spotify_track_meta_data_track_number AS spotify_track_number,
        track_meta_data.spotify_track_meta_data_popularity AS spotify_track_popularity,
        artists.spotify_artist_meta_data_artist_followers_total AS spotify_artist_followers_total,
        artists.spotify_artist_meta_data_artist_popularity AS spotify_artist_popularity,
        artists.spotify_artist_genre AS spotify_artist_genre,
        artists.spotify_artist_meta_data_artist_genres AS spotify_artist_genres,
        albums.spotify_album_meta_data_album_release_date AS spotify_album_release_date,
        albums.spotify_album_meta_data_album_total_tracks AS spotify_album_total_tracks,
        albums.spotify_album_meta_data_album_type AS spotify_album_type,
        albums.spotify_album_meta_data_album_artist_ids AS spotify_album_artist_ids,
        albums.spotify_album_meta_data_album_artist_names AS spotify_album_artist_names,
        albums.spotify_album_meta_data_album_label AS spotify_album_label,
        albums.spotify_album_meta_data_album_popularity AS spotify_album_popularity
    FROM tracks
    LEFT JOIN track_meta_data
        ON tracks.spotify_track_id = track_meta_data.spotify_track_meta_data_track_id
    LEFT JOIN artists
        ON track_meta_data.spotify_track_meta_data_artist_id = artists.spotify_artist_meta_data_artist_id
    LEFT JOIN albums
        ON track_meta_data.spotify_track_meta_data_album_id = albums.spotify_album_meta_data_album_id
)

SELECT * FROM full_table
