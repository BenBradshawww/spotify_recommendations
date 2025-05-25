WITH tracks AS (
    SELECT DISTINCT
        track.spotify_track_id,
        track.spotify_track_played_at,
        track_meta_data.spotify_track_meta_data_track_duration_ms
    FROM {{ ref('int_spotify__all_heard_tracks') }} AS track
    LEFT JOIN {{ ref('base_spotify__track_meta_data') }} AS track_meta_data
        ON track.spotify_track_id = track_meta_data.spotify_track_meta_data_track_id
),

lifetime_track_counts AS (
    SELECT 
        spotify_track_id,
        COUNT(*) AS play_count
    FROM tracks
    GROUP BY spotify_track_id
),

three_month_track_counts AS (
    SELECT 
        spotify_track_id,
        COUNT(*) AS three_month_play_count
    FROM tracks
    WHERE CAST(spotify_track_played_at AS TIMESTAMP WITH TIME ZONE) > CURRENT_TIMESTAMP - INTERVAL '3 months'
    GROUP BY spotify_track_id
),

one_year_track_counts AS (
    SELECT 
        spotify_track_id,
        COUNT(*) AS one_year_play_count
    FROM tracks
    WHERE CAST(spotify_track_played_at AS TIMESTAMP WITH TIME ZONE) > CURRENT_TIMESTAMP - INTERVAL '1 year'
    GROUP BY spotify_track_id
),

track_listen_times AS (
    SELECT
        spotify_track_id,
        spotify_track_played_at,
        spotify_track_meta_data_track_duration_ms,
        LEAD(spotify_track_played_at) OVER (ORDER BY spotify_track_played_at) AS next_track_played_at
    FROM tracks
),

time_listening_to_tracks AS (
    SELECT    
        spotify_track_id,
        spotify_track_played_at,
        spotify_track_meta_data_track_duration_ms,
        (EXTRACT(EPOCH FROM (next_track_played_at - spotify_track_played_at)) * 1000)::BIGINT AS time_to_next_track_ms
    FROM track_listen_times
),

skipped_tracks AS (
    SELECT
        spotify_track_id,
        spotify_track_played_at,
        LEAST(time_to_next_track_ms, spotify_track_meta_data_track_duration_ms) / NULLIF(spotify_track_meta_data_track_duration_ms, 0) AS prop_listened_to_track,
        time_to_next_track_ms > (spotify_track_meta_data_track_duration_ms*0.9) AS track_skipped
    FROM time_listening_to_tracks
),

lifetime_skipped_tracks_stats AS (
    SELECT
        spotify_track_id,
        AVG(prop_listened_to_track) AS lifetime_avg_time_listened_to_track,
        AVG(
            CASE WHEN track_skipped THEN 1 ELSE 0 END
        ) AS lifetime_prop_track_skipped
    FROM skipped_tracks
    GROUP BY spotify_track_id
),

three_month_skipped_tracks_stats AS (
    SELECT
        spotify_track_id,
        AVG(
            CASE WHEN track_skipped THEN 1 ELSE 0 END
        ) AS three_month_prop_skipped
    FROM skipped_tracks
    WHERE CAST(spotify_track_played_at AS TIMESTAMP WITH TIME ZONE) > CURRENT_TIMESTAMP - INTERVAL '3 months'
    GROUP BY spotify_track_id
),

year_skipped_tracks_stats AS (
    SELECT
        spotify_track_id,
        AVG(
            CASE
                WHEN track_skipped THEN 1 ELSE 0 END
        ) AS year_prop_skipped
    FROM skipped_tracks
    WHERE CAST(spotify_track_played_at AS TIMESTAMP WITH TIME ZONE) > CURRENT_TIMESTAMP - INTERVAL '1 year'
    GROUP BY spotify_track_id
),


track_facts AS (
    SELECT 
        lifetime_track_counts.spotify_track_id,
        lifetime_track_counts.play_count,
        three_month_track_counts.three_month_play_count,
        one_year_track_counts.one_year_play_count,
        lifetime_skipped_tracks_stats.lifetime_avg_time_listened_to_track,
        lifetime_skipped_tracks_stats.lifetime_prop_track_skipped,
        three_month_skipped_tracks_stats.three_month_prop_skipped,
        year_skipped_tracks_stats.year_prop_skipped
    FROM lifetime_track_counts
    LEFT JOIN three_month_track_counts
        ON lifetime_track_counts.spotify_track_id = three_month_track_counts.spotify_track_id
    LEFT JOIN one_year_track_counts 
        ON lifetime_track_counts.spotify_track_id = one_year_track_counts.spotify_track_id
    LEFT JOIN lifetime_skipped_tracks_stats
        ON lifetime_track_counts.spotify_track_id = lifetime_skipped_tracks_stats.spotify_track_id
    LEFT JOIN three_month_skipped_tracks_stats
        ON lifetime_track_counts.spotify_track_id = three_month_skipped_tracks_stats.spotify_track_id
    LEFT JOIN year_skipped_tracks_stats
        ON lifetime_track_counts.spotify_track_id = year_skipped_tracks_stats.spotify_track_id
)

SELECT * FROM track_facts


