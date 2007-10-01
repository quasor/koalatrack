class CreatePlaylistTestCases < ActiveRecord::Migration
  def self.up
    create_table :playlist_test_cases do |t|
      t.integer :playlist_id
      t.integer :test_case_id
      t.integer :test_case_version
      t.integer :user_id

      t.timestamps 
    end
  end

  def self.down
    drop_table :playlist_test_cases
  end
end
