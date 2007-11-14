class AddActiveToTestCase < ActiveRecord::Migration
  def self.up
    add_column :test_cases, :active, :boolean, :default => true
    add_column :test_case_versions, :active, :boolean, :default => true
  end

  def self.down
    remove_column :test_cases, :active  
    remove_column :test_case_versions, :active  
  end
end
