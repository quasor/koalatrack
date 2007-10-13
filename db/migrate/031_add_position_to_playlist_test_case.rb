class AddPositionToPlaylistTestCase < ActiveRecord::Migration
  def self.up
    add_column :playlist_test_cases, :position, :integer  
  end

  def self.down
    remove_column :playlist_test_cases, :position  
  end
end
