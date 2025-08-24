WITH all_tracks AS (
  SELECT
    spotify_track_id,
    spotify_track_name,
    spotify_track_heard,
    spotify_album_id,
    spotify_artist_id,
    spotify_artist_genre
  FROM {{ ref('mart_spotify__all_tracks') }}
),

track_facts AS (
  SELECT
    spotify_track_id,
    play_count,
    three_month_play_count,
    one_year_play_count,
    lifetime_avg_time_listened_to_track,
    lifetime_prop_track_skipped,
    three_month_prop_skipped,
    year_prop_skipped,
    max_streams_in_any_month
  FROM {{ ref('int_spotify__track_facts') }}
),

album_facts AS (
  SELECT
    spotify_album_id,
    three_month_album_listen_count,
    one_year_album_listen_count,
    lifetime_album_listen_count,
    three_month_album_listen_prop,
    one_year_album_listen_prop
  FROM {{ ref('int_spotify__album_facts') }}
),

artist_facts AS (
  SELECT
    spotify_artist_id,
    three_month_artist_listen_count,
    one_year_artist_listen_count,
    lifetime_artist_listen_count,
    three_month_artist_listen_prop,
    one_year_artist_listen_prop
  FROM {{ ref('int_spotify__artist_facts') }}
),

genre_facts AS (
  SELECT
    spotify_track_genre,
    three_month_genre_listen_count,
    one_year_genre_listen_count,
    lifetime_genre_listen_count,
    three_month_genre_listen_prop,
    one_year_genre_listen_prop
  FROM {{ ref('int_spotify__genre_facts') }}
),

all_tracks_with_facts AS (
  SELECT
    all_tracks.spotify_track_id,
    all_tracks.spotify_track_name,
    all_tracks.spotify_track_heard,
    all_tracks.spotify_album_id,
    all_tracks.spotify_artist_id,
    all_tracks.spotify_artist_genre,
    track_facts.play_count,
    track_facts.three_month_play_count,
    track_facts.one_year_play_count,
    track_facts.lifetime_avg_time_listened_to_track,
    track_facts.lifetime_prop_track_skipped,
    track_facts.three_month_prop_skipped,
    track_facts.year_prop_skipped,
    track_facts.max_streams_in_any_month,
    album_facts.three_month_album_listen_count,
    album_facts.one_year_album_listen_count,
    album_facts.lifetime_album_listen_count,
    album_facts.three_month_album_listen_prop,
    album_facts.one_year_album_listen_prop,
    artist_facts.three_month_artist_listen_count,
    artist_facts.one_year_artist_listen_count,
    artist_facts.lifetime_artist_listen_count,
    artist_facts.three_month_artist_listen_prop,
    artist_facts.one_year_artist_listen_prop,
    genre_facts.three_month_genre_listen_count,
    genre_facts.one_year_genre_listen_count,
    genre_facts.lifetime_genre_listen_count,
    genre_facts.three_month_genre_listen_prop,
    genre_facts.one_year_genre_listen_prop
  FROM all_tracks
  LEFT JOIN track_facts
    ON all_tracks.spotify_track_id = track_facts.spotify_track_id
  LEFT JOIN album_facts
    ON all_tracks.spotify_album_id = album_facts.spotify_album_id
  LEFT JOIN artist_facts
    ON all_tracks.spotify_artist_id = artist_facts.spotify_artist_id
  LEFT JOIN genre_facts
    ON all_tracks.spotify_artist_genre = genre_facts.spotify_track_genre
)

SELECT * FROM all_tracks_with_facts