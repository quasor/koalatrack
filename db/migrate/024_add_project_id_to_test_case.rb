class AddProjectIdToTestCase < ActiveRecord::Migration
  def self.up
    add_column :test_cases, :project_id, :string  
    TestCase.drop_versioned_table
    TestCase.create_versioned_table
  end

  def self.down
    remove_column :test_cases, :project_id  
  end
end
