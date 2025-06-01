with all_tracks as (
    SELECT
        spotify_track_id,
        spotify_track_name,
        spotify_track_heard,
        spotify_album_id,
        spotify_album_name,
        spotify_artist_id,
        spotify_artist_name,
        spotify_track_release_date,
        spotify_track_duration_ms,
        spotify_track_number,
        spotify_track_popularity,
        spotify_artist_followers_total,
        spotify_artist_popularity,
        spotify_artist_genre,
        spotify_artist_genres,
        spotify_album_release_date,
        spotify_album_total_tracks,
        spotify_album_type,
        spotify_album_artist_ids,
        spotify_album_artist_names,
        spotify_album_label,
        spotify_album_popularity
    FROM
        {{ ref("mart_spotify__all_tracks") }}
),

track_facts as (
    SELECT
        spotify_track_id,
        spotify_artist_id,
        spotify_album_id,
        spotify_artist_genre,
        play_count,
        three_month_play_count,
        one_year_play_count,
        lifetime_avg_time_listened_to_track,
        lifetime_prop_track_skipped,
        three_month_prop_skipped,
        year_prop_skipped,
        three_month_album_listen_count,
        one_year_album_listen_count,
        lifetime_album_listen_count,
        three_month_album_listen_prop,
        one_year_album_listen_prop,
        three_month_artist_listen_count,
        one_year_artist_listen_count,
        lifetime_artist_listen_count,
        three_month_artist_listen_prop,
        one_year_artist_listen_prop,
        three_month_genre_listen_count,
        one_year_genre_listen_count,
        lifetime_genre_listen_count,
        three_month_genre_listen_prop,
        one_year_genre_listen_prop
    FROM
        {{ ref("mart_spotify__track_facts") }}
)

SELECT
    all_tracks.spotify_track_id,
    all_tracks.spotify_track_name,
    all_tracks.spotify_track_heard,
    all_tracks.spotify_album_id,
    all_tracks.spotify_album_name,
    all_tracks.spotify_artist_id,
    all_tracks.spotify_artist_name,
    all_tracks.spotify_track_release_date,
    all_tracks.spotify_track_duration_ms,
    all_tracks.spotify_track_number,
    all_tracks.spotify_track_popularity,
    all_tracks.spotify_artist_followers_total,
    all_tracks.spotify_artist_popularity,
    all_tracks.spotify_artist_genre,
    all_tracks.spotify_artist_genres,
    all_tracks.spotify_album_release_date,
    all_tracks.spotify_album_total_tracks,
    all_tracks.spotify_album_type,
    all_tracks.spotify_album_artist_ids,
    all_tracks.spotify_album_artist_names,
    all_tracks.spotify_album_label,
    all_tracks.spotify_album_popularity,
    track_facts.three_month_prop_skipped,
    track_facts.year_prop_skipped,
    track_facts.three_month_artist_listen_prop,
    track_facts.one_year_artist_listen_prop,
    track_facts.three_month_album_listen_prop,
    track_facts.one_year_album_listen_prop,
    track_facts.three_month_genre_listen_prop,
    track_facts.one_year_genre_listen_prop,
    COALESCE(track_facts.play_count, 0) AS play_count,
    COALESCE(track_facts.three_month_play_count, 0) AS three_month_play_count,
    COALESCE(track_facts.one_year_play_count, 0) AS one_year_play_count,
    COALESCE(track_facts.lifetime_avg_time_listened_to_track, 0) AS lifetime_avg_time_listened_to_track,
    COALESCE(track_facts.lifetime_prop_track_skipped, 0) AS lifetime_prop_track_skipped,
    COALESCE(track_facts.three_month_album_listen_count, 0) AS three_month_album_listen_count,
    COALESCE(track_facts.one_year_album_listen_count, 0) AS one_year_album_listen_count,
    COALESCE(track_facts.lifetime_album_listen_count, 0) AS lifetime_album_listen_count,
    COALESCE(track_facts.three_month_artist_listen_count, 0) AS three_month_artist_listen_count,
    COALESCE(track_facts.one_year_artist_listen_count, 0) AS one_year_artist_listen_count,
    COALESCE(track_facts.lifetime_artist_listen_count, 0) AS lifetime_artist_listen_count,
    COALESCE(track_facts.three_month_genre_listen_count, 0) AS three_month_genre_listen_count,
    COALESCE(track_facts.one_year_genre_listen_count, 0) AS one_year_genre_listen_count,
    COALESCE(track_facts.lifetime_genre_listen_count, 0) AS lifetime_genre_listen_count
FROM all_tracks
LEFT JOIN track_facts
    ON all_tracks.spotify_track_id = track_facts.spotify_track_id
    AND all_tracks.spotify_artist_id = track_facts.spotify_artist_id
    AND all_tracks.spotify_album_id = track_facts.spotify_album_id
    AND all_tracks.spotify_artist_genre IS NOT DISTINCT FROM track_facts.spotify_artist_genre


