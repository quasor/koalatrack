class AddCategoryIdToTestCase < ActiveRecord::Migration
  def self.up
    add_column :test_cases, :category_id, :integer  
    add_column :categories, :children_count, :integer, :default => 0
  end

  def self.down
    remove_column :test_cases, :category_id  
    remove_column :categories, :children_count  
  end
end
