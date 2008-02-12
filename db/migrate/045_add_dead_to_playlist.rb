class AddDeadToPlaylist < ActiveRecord::Migration
  def self.up
    add_column :playlists, :dead, :boolean, :default => false
    Playlist.reset_column_information
    Playlist.rebuild_solr_index 300
    
  end

  def self.down
    remove_column :playlists, :dead  
  end
end
