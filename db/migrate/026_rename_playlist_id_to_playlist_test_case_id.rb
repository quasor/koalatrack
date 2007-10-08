class RenamePlaylistIdToPlaylistTestCaseId < ActiveRecord::Migration
  def self.up
    rename_column :test_case_executions, :playlist_id, :playlist_test_case_id
  end

  def self.down
    rename_column :test_case_executions, :playlist_test_case_id, :playlist_id 
  end
end
