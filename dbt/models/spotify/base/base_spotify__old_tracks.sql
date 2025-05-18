WITH source AS (
    SELECT
      *
    FROM {{ source('spotify', 'spotify_old_tracks') }}
),

model AS (
    SELECT
        spotify_old_tracks_track_id,
        spotify_old_tracks_created_at,
        spotify_old_tracks_updated_at,
        spotify_old_tracks_played_at,
        spotify_old_tracks_artist_name,
        spotify_old_tracks_track_name,
        spotify_old_tracks_album_name,
        spotify_old_tracks_ms_played,
        spotify_old_tracks_reason_start,
        spotify_old_tracks_reason_end,
        spotify_old_tracks_shuffle,
        spotify_old_tracks_skipped,
        spotify_old_tracks_offline
    FROM source
)

SELECT * FROM model
