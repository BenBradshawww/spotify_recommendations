CREATE TABLE IF NOT EXISTS spotify_old_tracks (
    spotify_old_tracks_id SERIAL PRIMARY KEY,
    spotify_old_tracks_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_old_tracks_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_old_tracks_track_id VARCHAR(255) NOT NULL,
    spotify_old_tracks_played_at TIMESTAMP NOT NULL,
    spotify_old_tracks_artist_name VARCHAR(255) NOT NULL,
    spotify_old_tracks_track_name VARCHAR(255) NOT NULL,
    spotify_old_tracks_album_name VARCHAR(255) NOT NULL,
    spotify_old_tracks_ms_played INT NOT NULL,
    spotify_old_tracks_reason_start VARCHAR(255) NOT NULL,
    spotify_old_tracks_reason_end VARCHAR(255) NOT NULL,
    spotify_old_tracks_shuffle BOOLEAN NOT NULL,
    spotify_old_tracks_skipped BOOLEAN NOT NULL,
    spotify_old_tracks_offline BOOLEAN NOT NULL,
    CONSTRAINT uq_played_at UNIQUE (spotify_old_tracks_played_at)
);

-- Create indexes
CREATE INDEX spotify_old_tracks_played_at_idx ON spotify_old_tracks USING btree (spotify_old_tracks_played_at);
CREATE INDEX spotify_old_tracks_track_id_idx ON spotify_old_tracks USING hash (spotify_old_tracks_track_id);

-- Comment on the table
COMMENT ON TABLE spotify_old_tracks IS 'Table to store the old tracks played by the user';

-- Comment on the columns
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_id IS 'Unique identifier for the old track';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_created_at IS 'Timestamp of when the old track was created';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_updated_at IS 'Timestamp of when the old track was last updated';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_track_id IS 'Spotify track ID of the old track';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_played_at IS 'Timestamp of when the old track was played';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_artist_name IS 'Artist name of the old track';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_track_name IS 'Track name of the old track';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_album_name IS 'Album name of the old track';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_ms_played IS 'Duration of the old track in milliseconds';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_reason_start IS 'Reason the old track was started';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_reason_end IS 'Reason the old track was ended';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_shuffle IS 'Whether the old track was shuffled';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_skipped IS 'Whether the old track was skipped';
COMMENT ON COLUMN spotify_old_tracks.spotify_old_tracks_offline IS 'Whether the old track was played offline';