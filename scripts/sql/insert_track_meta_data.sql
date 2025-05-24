INSERT INTO spotify_track_meta_data (
    spotify_track_meta_data_track_id,
    spotify_track_meta_data_track_name,
    spotify_track_meta_data_album_id,
    spotify_track_meta_data_album_name,
    spotify_track_meta_data_artist_ids,
    spotify_track_meta_data_artist_names,
    spotify_track_meta_data_track_release_date,
    spotify_track_meta_data_track_duration_ms,
    spotify_track_meta_data_track_number,
    spotify_track_meta_data_popularity
) VALUES %s
ON CONFLICT (spotify_track_meta_data_track_id) 
DO UPDATE SET 
  spotify_track_meta_data_updated_at = CURRENT_TIMESTAMP
