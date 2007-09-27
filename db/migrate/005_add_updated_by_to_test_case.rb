class AddUpdatedByToTestCase < ActiveRecord::Migration
  def self.up
    add_column :test_cases, :updated_by, :integer  
  end

  def self.down
    remove_column :test_cases, :updated_by  
  end
end
