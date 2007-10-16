class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :test_cases, :category_id
    add_index :categories, :parent_id
    add_index :playlist_test_cases, :playlist_id       
    add_index :playlist_test_cases, :test_case_id
    add_index :test_case_executions, :test_case_id
    add_index :test_case_executions, :playlist_test_case_id
    categories = Category.find :all
    for c in categories
      c.update_attributes(:children_count => c.children(true).size)
    end
  end

  def self.down
    remove_index :test_cases, :category_id
    remove_index :categories, :parent_id
    remove_index :playlist_test_cases, :playlist_id       
    remove_index :playlist_test_cases, :test_case_id
    remove_index :test_case_executions, :test_case_id
    remove_index :test_case_executions, :playlist_test_case_id
  end
end
