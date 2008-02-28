class AddClasspathToTestCase < ActiveRecord::Migration
  def self.up
    add_column :test_cases, :automation_class_path, :string  
    add_column :test_case_versions, :automation_class_path, :string  
  end

  def self.down
    remove_column :test_cases, :automation_class_path  
    remove_column :test_case_versions, :automation_class_path  
  end
end
