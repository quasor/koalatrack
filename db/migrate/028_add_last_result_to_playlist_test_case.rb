class AddLastResultToPlaylistTestCase < ActiveRecord::Migration
  def self.up
    add_column :playlist_test_cases, :last_result, :integer, :default => 0  
  end

  def self.down
    remove_column :playlist_test_cases, :last_result  
  end
end
