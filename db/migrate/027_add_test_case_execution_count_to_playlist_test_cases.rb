class AddTestCaseExecutionCountToPlaylistTestCases < ActiveRecord::Migration
  def self.up
    add_column :playlist_test_cases, :test_case_executions_count, :integer, :default => 0 
  end

  def self.down
    remove_column :playlist_test_cases, :test_case_executions_count  
  end
end
