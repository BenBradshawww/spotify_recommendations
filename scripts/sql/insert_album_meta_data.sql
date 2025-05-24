INSERT INTO spotify_album_meta_data (
    spotify_album_meta_data_album_id,
    spotify_album_meta_data_album_name,
    spotify_album_meta_data_album_release_date,
    spotify_album_meta_data_album_total_tracks,
    spotify_album_meta_data_album_type,
    spotify_album_meta_data_album_artist_ids,
    spotify_album_meta_data_album_artist_names,
    spotify_album_meta_data_album_label,
    spotify_album_meta_data_album_popularity
) VALUES %s
ON CONFLICT (spotify_album_meta_data_album_id) 
DO UPDATE SET 
  spotify_album_meta_data_updated_at = CURRENT_TIMESTAMP
