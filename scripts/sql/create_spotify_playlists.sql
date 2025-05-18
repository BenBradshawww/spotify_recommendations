CREATE TABLE spotify_playlists (
    spotify_playlists_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    spotify_playlists_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_playlists_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    spotify_playlists_playlist_id VARCHAR(255),
    spotify_playlists_playlist_name VARCHAR(255),
    spotify_playlists_owner_id VARCHAR(255),
    spotify_playlists_owner_name VARCHAR(255),
    spotify_playlists_date DATE,
    spotify_playlists_added_at TIMESTAMP,
    spotify_playlists_added_by_id VARCHAR(255),
    spotify_playlists_track_id VARCHAR(255),
    spotify_playlists_track_name VARCHAR(255),
    spotify_playlists_track_artists JSONB,
    spotify_playlists_track_artists_id JSONB,
    spotify_playlists_track_album_name VARCHAR(255),
    spotify_playlists_track_track_number INT,
    spotify_playlists_track_duration_ms INT,
    spotify_playlists_track_album_release_date DATE,
    spotify_playlists_track_popularity INT,
    CONSTRAINT unique_spotify_playlists_id_track_id_date UNIQUE (spotify_playlists_id, spotify_playlists_track_id, spotify_playlists_date)
);

-- Create indexes
CREATE INDEX idx_spotify_playlists_id ON spotify_playlists USING hash (spotify_playlists_id);
CREATE INDEX idx_spotify_playlists_date ON spotify_playlists USING btree (spotify_playlists_date);

-- Comment on the table
COMMENT ON TABLE spotify_playlists IS 'Table to store Spotify playlists';

-- Comment on the columns
COMMENT ON COLUMN spotify_playlists.spotify_playlists_id IS 'The ID of the Spotify playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_created_at IS 'The date and time the playlist was created';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_updated_at IS 'The date and time the playlist was last updated';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_playlist_id IS 'The ID of the Spotify playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_playlist_name IS 'The name of the Spotify playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_owner_id IS 'The ID of the Spotify playlist owner';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_owner_name IS 'The name of the Spotify playlist owner';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_date IS 'The date the playlist was added';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_added_at IS 'The date and time the track was added';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_added_by_id IS 'The ID of the user who added the track';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_track_id IS 'The ID of the track in the playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_track_name IS 'The name of the track in the playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_track_artists IS 'The artists of the track in the playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_track_artists_id IS 'The IDs of the artists of the track in the playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_track_album_name IS 'The name of the album of the track in the playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_track_track_number IS 'The track number of the track in the playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_track_duration_ms IS 'The duration of the track in milliseconds in the playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_track_album_release_date IS 'The release date of the album of the track in the playlist';
COMMENT ON COLUMN spotify_playlists.spotify_playlists_track_popularity IS 'The popularity of the track in the playlist';



