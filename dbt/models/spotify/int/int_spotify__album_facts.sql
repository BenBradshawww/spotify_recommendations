WITH all_heard_tracks AS (
    SELECT
        spotify_track_id,
        spotify_track_name,
        spotify_track_played_at
    FROM {{ ref('int_spotify__all_heard_tracks') }}
),

album_ids AS (
    SELECT
        spotify_track_meta_data_track_id AS spotify_track_id,
        spotify_track_meta_data_track_name AS spotify_track_name,
        spotify_track_meta_data_album_id AS spotify_album_id
    FROM {{ ref('base_spotify__track_meta_data') }}
),

tracks_with_album_ids AS (
    SELECT 
        all_heard_tracks.spotify_track_id,
        all_heard_tracks.spotify_track_name,
        all_heard_tracks.spotify_track_played_at,
        album_ids.spotify_album_id
    FROM all_heard_tracks
    LEFT JOIN album_ids
        ON all_heard_tracks.spotify_track_id = album_ids.spotify_track_id
),

three_month_album_listen_counts AS (
    SELECT
        spotify_album_id,
        COUNT(spotify_track_id) AS three_month_album_listen_count
    FROM tracks_with_album_ids
    WHERE spotify_track_played_at > CURRENT_DATE - INTERVAL '3 months'
    GROUP BY spotify_album_id
),


one_year_album_listen_counts AS (
    SELECT
        spotify_album_id,
        COUNT(spotify_track_id) AS one_year_album_listen_count
    FROM tracks_with_album_ids
    WHERE spotify_track_played_at > CURRENT_DATE - INTERVAL '1 year'
    GROUP BY spotify_album_id 
),

lifetime_album_listen_counts AS (
    SELECT
        spotify_album_id,
        COUNT(spotify_track_id) AS lifetime_album_listen_count
    FROM tracks_with_album_ids
    GROUP BY spotify_album_id
),

album_ids_with_listen_counts AS (
    SELECT DISTINCT
        album_ids.spotify_album_id,
        COALESCE(three_month_album_listen_counts.three_month_album_listen_count, 0) AS three_month_album_listen_count,
        COALESCE(one_year_album_listen_counts.one_year_album_listen_count, 0) AS one_year_album_listen_count,
        lifetime_album_listen_counts.lifetime_album_listen_count AS lifetime_album_listen_count,
        COALESCE(three_month_album_listen_counts.three_month_album_listen_count::FLOAT / lifetime_album_listen_counts.lifetime_album_listen_count::FLOAT, 0) AS three_month_album_listen_prop,
        COALESCE(one_year_album_listen_counts.one_year_album_listen_count::FLOAT / lifetime_album_listen_counts.lifetime_album_listen_count::FLOAT, 0) AS one_year_album_listen_prop
    FROM album_ids
    LEFT JOIN three_month_album_listen_counts
        ON album_ids.spotify_album_id = three_month_album_listen_counts.spotify_album_id
    LEFT JOIN one_year_album_listen_counts
        ON album_ids.spotify_album_id = one_year_album_listen_counts.spotify_album_id
    LEFT JOIN lifetime_album_listen_counts
        ON album_ids.spotify_album_id = lifetime_album_listen_counts.spotify_album_id
)

SELECT * FROM album_ids_with_listen_counts
