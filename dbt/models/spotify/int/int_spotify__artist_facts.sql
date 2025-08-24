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

tracks_with_artist_ids AS (
    SELECT 
        all_heard_tracks.spotify_track_id,
        all_heard_tracks.spotify_track_name,
        all_heard_tracks.spotify_track_played_at,
        artist_ids.spotify_artist_id
    FROM all_heard_tracks
    LEFT JOIN artist_ids
        ON all_heard_tracks.spotify_track_id = artist_ids.spotify_track_id
),

three_month_artist_listen_counts AS (
    SELECT
        spotify_artist_id,
        COUNT(spotify_track_id) AS three_month_artist_listen_count
    FROM tracks_with_artist_ids
    WHERE spotify_track_played_at > CURRENT_DATE - INTERVAL '3 months'
    GROUP BY spotify_artist_id
),

one_year_artist_listen_counts AS (
    SELECT
        spotify_artist_id,
        COUNT(spotify_track_id) AS one_year_artist_listen_count
    FROM tracks_with_artist_ids
    WHERE spotify_track_played_at > CURRENT_DATE - INTERVAL '1 year'
    GROUP BY spotify_artist_id 
),

lifetime_artist_listen_counts AS (
    SELECT
        spotify_artist_id,
        COUNT(spotify_track_id) AS lifetime_artist_listen_count
    FROM tracks_with_artist_ids
    GROUP BY spotify_artist_id
),

artist_ids_with_listen_counts AS (
    SELECT DISTINCT
        artist_ids.spotify_artist_id,
        COALESCE(three_month_artist_listen_counts.three_month_artist_listen_count, 0) AS three_month_artist_listen_count,
        COALESCE(one_year_artist_listen_counts.one_year_artist_listen_count, 0) AS one_year_artist_listen_count,
        lifetime_artist_listen_counts.lifetime_artist_listen_count AS lifetime_artist_listen_count,
        COALESCE(three_month_artist_listen_counts.three_month_artist_listen_count::FLOAT / lifetime_artist_listen_counts.lifetime_artist_listen_count::FLOAT, 0) AS three_month_artist_listen_prop,
        COALESCE(one_year_artist_listen_counts.one_year_artist_listen_count::FLOAT / lifetime_artist_listen_counts.lifetime_artist_listen_count::FLOAT, 0) AS one_year_artist_listen_prop
    FROM artist_ids
    LEFT JOIN three_month_artist_listen_counts
        ON artist_ids.spotify_artist_id = three_month_artist_listen_counts.spotify_artist_id
    LEFT JOIN one_year_artist_listen_counts
        ON artist_ids.spotify_artist_id = one_year_artist_listen_counts.spotify_artist_id
    LEFT JOIN lifetime_artist_listen_counts
        ON artist_ids.spotify_artist_id = lifetime_artist_listen_counts.spotify_artist_id
)

SELECT * FROM artist_ids_with_listen_counts
