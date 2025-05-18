-- Create the table
CREATE TABLE IF NOT EXISTS spotify_track_meta_data (
    spotify_track_meta_data_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    spotify_track_meta_data_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_track_meta_data_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_track_meta_data_track_id VARCHAR(255) NOT NULL,
    spotify_track_meta_data_track_name VARCHAR(255) NOT NULL,
    spotify_track_meta_data_album VARCHAR(255) NOT NULL,
    spotify_track_meta_data_artists JSONB NOT NULL,
    spotify_track_meta_data_track_release_date VARCHAR(255) NOT NULL,
    spotify_track_meta_data_track_duration_ms FLOAT NOT NULL,
    spotify_track_meta_data_track_number INT NOT NULL,
    spotify_track_meta_data_popularity INT NOT NULL,
    CONSTRAINT uq_track_id UNIQUE (spotify_track_meta_data_track_id)
);

-- Create indexes
CREATE INDEX spotify_track_meta_data_track_id_idx ON spotify_track_meta_data USING hash (spotify_track_meta_data_track_id);

-- Comment on the table
COMMENT ON TABLE spotify_track_meta_data IS 'Table to store the metadata of the last tracks played by the user';

-- Comment on the columns
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_id IS 'Unique identifier for the track metadata';
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_created_at IS 'Timestamp of when the track metadata was created';
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_updated_at IS 'Timestamp of when the track metadata was last updated';
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_track_id IS 'Spotify track ID of the last track played';
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_track_name IS 'Track name of the last track played';
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_album IS 'Album name of the last track played';
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_artists IS 'Artists of the last track played';
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_track_release_date IS 'Release date of the last track played';
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_track_number IS 'Track number of the last track played';
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_track_duration_ms IS 'Duration of the last track played';
COMMENT ON COLUMN spotify_track_meta_data.spotify_track_meta_data_popularity IS 'Popularity of the last track played';


