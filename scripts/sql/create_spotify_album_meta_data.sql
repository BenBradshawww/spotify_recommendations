-- Create the table
CREATE TABLE IF NOT EXISTS spotify_album_meta_data (
    spotify_album_meta_data_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    spotify_album_meta_data_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_album_meta_data_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_album_meta_data_album_id VARCHAR(255) NOT NULL,
    spotify_album_meta_data_album_name VARCHAR(255) NOT NULL,
    spotify_album_meta_data_album_release_date DATE,
    spotify_album_meta_data_album_total_tracks INT,
    spotify_album_meta_data_album_type VARCHAR(255),
    spotify_album_meta_data_album_artist_ids JSONB,
    spotify_album_meta_data_album_artist_names JSONB,
    spotify_album_meta_data_album_genres JSONB,
    spotify_album_meta_data_album_label VARCHAR(255),
    spotify_album_meta_data_album_popularity INT,
    CONSTRAINT uq_album_id UNIQUE (spotify_album_meta_data_album_id)
);


-- Create indexes
CREATE INDEX spotify_album_meta_data_album_id_idx ON spotify_album_meta_data USING hash (spotify_album_meta_data_album_id);

-- Comment on the table
COMMENT ON TABLE spotify_album_meta_data IS 'Table to store the metadata of the albums';

-- Comment on the columns
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_id IS 'Unique identifier for the album metadata';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_created_at IS 'Timestamp of when the album metadata was created';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_updated_at IS 'Timestamp of when the album metadata was last updated';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_album_id IS 'Spotify album ID of the album';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_album_name IS 'Name of the album';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_album_release_date IS 'Release date of the album';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_album_total_tracks IS 'Total tracks of the album';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_album_type IS 'Type of the album';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_album_artist_ids IS 'Artist IDs in the album';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_album_artist_names IS 'Artist names in the album';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_album_genres IS 'Genres of the album';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_album_label IS 'Label of the album';
COMMENT ON COLUMN spotify_album_meta_data.spotify_album_meta_data_album_popularity IS 'Popularity of the album';
