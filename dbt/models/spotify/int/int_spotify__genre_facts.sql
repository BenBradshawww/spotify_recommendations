WITH all_heard_tracks AS (
    SELECT
        spotify_track_id,
        spotify_track_name,
        spotify_track_played_at
    FROM {{ ref('int_spotify__all_heard_tracks') }}
),

artist_ids AS (
    SELECT
        spotify_track_meta_data_track_id AS spotify_track_id,
        spotify_track_meta_data_track_name AS spotify_track_name,
        jsonb_array_elements_text(spotify_track_meta_data_artist_ids) AS spotify_artist_id
    FROM {{ ref('base_spotify__track_meta_data') }}
),

genres AS (
    SELECT
        spotify_artist_meta_data_artist_id AS spotify_artist_id,
        jsonb_array_elements_text(spotify_artist_meta_data_artist_genres) AS spotify_track_genre
    FROM {{ ref('base_spotify__artist_meta_data') }}
),

tracks_with_genre_ids AS (
    SELECT 
        all_heard_tracks.spotify_track_id,
        all_heard_tracks.spotify_track_name,
        all_heard_tracks.spotify_track_played_at,
        genres.spotify_track_genre
    FROM all_heard_tracks
    LEFT JOIN artist_ids
        ON all_heard_tracks.spotify_track_id = artist_ids.spotify_track_id
    LEFT JOIN genres
        ON artist_ids.spotify_artist_id = genres.spotify_artist_id
),

three_month_genre_listen_counts AS (
    SELECT
        spotify_track_genre,
        COUNT(spotify_track_id) AS three_month_genre_listen_count
    FROM tracks_with_genre_ids
    WHERE spotify_track_played_at > CURRENT_DATE - INTERVAL '3 months'
    GROUP BY spotify_track_genre
),


one_year_genre_listen_counts AS (
    SELECT
        spotify_track_genre,
        COUNT(spotify_track_id) AS one_year_genre_listen_count
    FROM tracks_with_genre_ids
    WHERE spotify_track_played_at > CURRENT_DATE - INTERVAL '1 year'
    GROUP BY spotify_track_genre 
),

lifetime_genre_listen_counts AS (
    SELECT
        spotify_track_genre,
        COUNT(spotify_track_id) AS lifetime_genre_listen_count
    FROM tracks_with_genre_ids
    GROUP BY spotify_track_genre
),

genre_ids_with_listen_counts AS (
    SELECT DISTINCT
        genres.spotify_track_genre,
        COALESCE(three_month_genre_listen_counts.three_month_genre_listen_count, 0) AS three_month_genre_listen_count,
        COALESCE(one_year_genre_listen_counts.one_year_genre_listen_count, 0) AS one_year_genre_listen_count,
        lifetime_genre_listen_counts.lifetime_genre_listen_count AS lifetime_genre_listen_count,
        (three_month_genre_listen_counts.three_month_genre_listen_count / lifetime_genre_listen_counts.lifetime_genre_listen_count) AS three_month_genre_listen_prop,
        (one_year_genre_listen_counts.one_year_genre_listen_count / lifetime_genre_listen_counts.lifetime_genre_listen_count) AS one_year_genre_listen_prop
    FROM genres
    LEFT JOIN three_month_genre_listen_counts
        ON genres.spotify_track_genre = three_month_genre_listen_counts.spotify_track_genre
    LEFT JOIN one_year_genre_listen_counts
        ON genres.spotify_track_genre = one_year_genre_listen_counts.spotify_track_genre
    LEFT JOIN lifetime_genre_listen_counts
        ON genres.spotify_track_genre = lifetime_genre_listen_counts.spotify_track_genre
)

SELECT * FROM genre_ids_with_listen_counts