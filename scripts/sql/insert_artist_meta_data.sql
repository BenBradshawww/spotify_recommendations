INSERT INTO spotify_artist_meta_data (
    spotify_artist_meta_data_artist_id,
    spotify_artist_meta_data_artist_name,
    spotify_artist_meta_data_artist_followers_total,
    spotify_artist_meta_data_artist_popularity,
    spotify_artist_meta_data_artist_genres
) VALUES %s
ON CONFLICT (spotify_artist_meta_data_artist_id) 
DO UPDATE SET 
  spotify_artist_meta_data_updated_at = CURRENT_TIMESTAMP
