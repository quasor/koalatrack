class CreateTestCaseExecutions < ActiveRecord::Migration
  def self.up
    create_table :test_case_executions do |t|
      t.integer :playlist_id
      t.integer :test_case_id
      t.integer :test_case_version
      t.integer :user_id
      t.integer :result
      t.string :bug_id
      t.text :comment

      t.timestamps 
    end
  end

  def self.down
    drop_table :test_case_executions
  end
end
