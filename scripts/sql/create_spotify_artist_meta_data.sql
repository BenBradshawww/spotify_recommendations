-- Create the table
CREATE TABLE IF NOT EXISTS spotify_artist_meta_data (
    spotify_artist_meta_data_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    spotify_artist_meta_data_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_artist_meta_data_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_artist_meta_data_artist_id VARCHAR(255) NOT NULL,
    spotify_artist_meta_data_artist_name VARCHAR(255) NOT NULL,
    spotify_artist_meta_data_artist_followers_total INT,
    spotify_artist_meta_data_artist_popularity INT,
    spotify_artist_meta_data_artist_genres JSONB,
    CONSTRAINT uq_artist_id UNIQUE (spotify_artist_meta_data_artist_id)
);


-- Create indexes
CREATE INDEX spotify_artist_meta_data_artist_id_idx ON spotify_artist_meta_data USING hash (spotify_artist_meta_data_artist_id);

-- Comment on the table
COMMENT ON TABLE spotify_artist_meta_data IS 'Table to store the metadata of the artists';

-- Comment on the columns
COMMENT ON COLUMN spotify_artist_meta_data.spotify_artist_meta_data_id IS 'Unique identifier for the artist metadata';
COMMENT ON COLUMN spotify_artist_meta_data.spotify_artist_meta_data_created_at IS 'Timestamp of when the artist metadata was created';
COMMENT ON COLUMN spotify_artist_meta_data.spotify_artist_meta_data_updated_at IS 'Timestamp of when the artist metadata was last updated';
COMMENT ON COLUMN spotify_artist_meta_data.spotify_artist_meta_data_artist_id IS 'Spotify artist ID of the artist';
COMMENT ON COLUMN spotify_artist_meta_data.spotify_artist_meta_data_artist_name IS 'Name of the artist';
COMMENT ON COLUMN spotify_artist_meta_data.spotify_artist_meta_data_artist_followers_total IS 'Total followers of the artist';
COMMENT ON COLUMN spotify_artist_meta_data.spotify_artist_meta_data_artist_popularity IS 'Popularity of the artist';
COMMENT ON COLUMN spotify_artist_meta_data.spotify_artist_meta_data_artist_genres IS 'Genres of the artist';
