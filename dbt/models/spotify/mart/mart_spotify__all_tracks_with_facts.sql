WITH all_tracks AS (
    SELECT
    *
  FROM {{ ref('mart_spotify__all_tracks') }}
),

album_facts AS (
  SELECT
    *   
  FROM {{ ref('int_spotify__album_facts') }}
),

artist_facts AS (
  SELECT
    *
  FROM {{ ref('int_spotify__artist_facts') }}
),

genre_facts AS (
  SELECT
    *
  FROM {{ ref('int_spotify__genre_facts') }}
),

genres AS (
    SELECT
        *
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
    genre_facts.lifetime_genre_listen_count
  FROM all_tracks
  LEFT JOIN album_facts
    ON all_tracks.spotify_album_id = album_facts.spotify_album_id
  LEFT JOIN artist_facts
    ON all_tracks.spotify_artist_id = artist_facts.spotify_artist_id
  LEFT JOIN genre_facts
    ON all_tracks.spotify_artist_genre = genre_facts.spotify_track_genre
)

SELECT * FROM all_tracks_with_facts