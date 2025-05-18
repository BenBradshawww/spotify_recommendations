WITH track_counts AS (
    SELECT 
        spotify_track_id,
        COUNT(*) AS play_count
    FROM int_spotify__all_heard_tracks
    GROUP BY spotify_track_id
),

recent_track_counts AS (
    SELECT 
        spotify_track_id,
        COUNT(*) AS recent_play_count
    FROM int_spotify__all_heard_tracks
    WHERE spotify_track_played_at > CURRENT_TIMESTAMP - INTERVAL '3 months'
    GROUP BY spotify_track_id
),

year_track_counts AS (
    SELECT 
        spotify_track_id,
        COUNT(*) AS year_play_count
    FROM int_spotify__all_heard_tracks
    WHERE spotify_track_played_at > CURRENT_TIMESTAMP - INTERVAL '1 year'
    GROUP BY spotify_track_id
),

track_listen_times AS (
    SELECT
        spotify_track_id,
        spotify_track_played_at,
        spotify_track_duration_ms,
        LEAD(spotify_track_played_at) OVER (ORDER BY spotify_track_played_at) AS next_track_played_at
    FROM int_spotify__all_heard_tracks
),

time_listening_to_tracks AS (
    SELECT    
        spotify_track_id,
        spotify_track_played_at,
        spotify_track_duration_ms,
        (EXTRACT(EPOCH FROM (next_track_played_at - spotify_track_played_at)) * 1000)::BIGINT AS time_to_next_track_ms
    FROM track_listen_times
),

skipped_tracks AS (
    SELECT
        spotify_track_id,
        spotify_track_played_at,
        LEAST(time_to_next_track_ms, spotify_track_duration_ms) / spotify_track_duration_ms AS prop_listened_to_track,
        time_to_next_track_ms > (spotify_track_duration_ms*0.9) AS track_skipped
    FROM time_listening_to_tracks
),

skipped_tracks_stats AS (
    SELECT
        spotify_track_id,
        AVG(prop_listened_to_track) AS avg_time_listened_to_track,
        AVG(
            CASE WHEN track_skipped THEN 1 ELSE 0 END
        ) AS prop_track_skipped
    FROM skipped_tracks
    GROUP BY spotify_track_id
),

recent_skipped_tracks_stats AS (
    SELECT
        spotify_track_id,
        AVG(
            CASE WHEN track_skipped THEN 1 ELSE 0 END
        ) AS recent_prop_skipped
    FROM skipped_tracks
    WHERE spotify_track_played_at > CURRENT_TIMESTAMP - INTERVAL '3 months'
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
    WHERE spotify_track_played_at > CURRENT_TIMESTAMP - INTERVAL '1 year'
    GROUP BY spotify_track_id
),


track_replay_rate AS (
    SELECT
)


track_behaviorial_features AS (
    SELECT 
        track_counts.spotify_track_id,
        track_counts.play_count,
        recent_track_counts.recent_play_count,
        year_track_counts.year_play_count,
        skipped_tracks_stats.avg_time_listened_to_track,
        skipped_tracks_stats.prop_track_skipped,
        recent_skipped_tracks_stats.recent_prop_skipped,
        year_skipped_tracks_stats.year_prop_skipped
    FROM track_counts
    LEFT JOIN recent_track_counts
        ON track_counts.spotify_track_id = recent_track_counts.spotify_track_id
    LEFT JOIN year_track_counts 
        ON track_counts.spotify_track_id = year_track_counts.spotify_track_id
    LEFT JOIN skipped_tracks_stats
        ON track_counts.spotify_track_id = skipped_tracks_stats.spotify_track_id
    LEFT JOIN recent_skipped_tracks_stats
        ON track_counts.spotify_track_id = recent_skipped_tracks_stats.spotify_track_id
    LEFT JOIN year_skipped_tracks_stats
        ON track_counts.spotify_track_id = year_skipped_tracks_stats.spotify_track_id
)

SELECT * FROM track_behaviorial_features


