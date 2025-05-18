WITH source AS (
    SELECT
      *
    FROM {{ source('spotify', 'spotify_playlists') }}
),

model AS (
    SELECT
        spotify_playlists_id,
        spotify_playlists_created_at,
        spotify_playlists_updated_at,
        spotify_playlists_playlist_id,
        spotify_playlists_playlist_name,
        spotify_playlists_owner_id,
        spotify_playlists_owner_name,
        spotify_playlists_date,
        spotify_playlists_added_at,
        spotify_playlists_added_by_id,
        spotify_playlists_track_id,
        spotify_playlists_track_name,
        spotify_playlists_track_artists,
        spotify_playlists_track_artists_id,
        spotify_playlists_track_album_name,
        spotify_playlists_track_track_number,
        spotify_playlists_track_duration_ms,
        spotify_playlists_track_album_release_date,
        spotify_playlists_track_popularity
    FROM source
)

SELECT * FROM model
