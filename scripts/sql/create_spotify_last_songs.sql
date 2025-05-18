-- Create the table
CREATE TABLE IF NOT EXISTS spotify_recent_tracks (
    spotify_recent_track_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    spotify_recent_track_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_recent_track_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_recent_track_track_played_at TIMESTAMP NOT NULL,
    spotify_recent_track_track_id VARCHAR(255) NOT NULL,
    spotify_recent_track_artist_name VARCHAR(255) NOT NULL,
    spotify_recent_track_track_name VARCHAR(255) NOT NULL,
    CONSTRAINT uq_track_id UNIQUE (spotify_track_meta_data_track_id)
);

-- Create indexes
CREATE INDEX spotify_recent_tracks_track_played_at_idx ON spotify_recent_tracks USING btree (spotify_recent_tracks_track_played_at);
CREATE INDEX spotify_recent_tracks_track_id_idx ON spotify_recent_tracks USING hash (spotify_recent_tracks_track_id);

-- Comment on the table
COMMENT ON TABLE spotify_recent_tracks IS 'Table to store the recent tracks played by the user';

-- Comment on the columns
COMMENT ON COLUMN spotify_recent_tracks.spotify_recent_track_id IS 'Unique identifier for the last song played';
COMMENT ON COLUMN spotify_recent_tracks.spotify_recent_track_updated_at IS 'Timestamp of when the last song was played';
COMMENT ON COLUMN spotify_recent_tracks.spotify_recent_track_track_played_at IS 'Timestamp of when the last song was played';
COMMENT ON COLUMN spotify_recent_tracks.spotify_recent_track_track_id IS 'Spotify track ID of the last song played';
COMMENT ON COLUMN spotify_recent_tracks.spotify_recent_track_artist_name IS 'Artist name of the last song played';
COMMENT ON COLUMN spotify_recent_tracks.spotify_recent_track_track_name IS 'Track name of the last song played';
