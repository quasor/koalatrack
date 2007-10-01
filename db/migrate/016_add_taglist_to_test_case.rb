class AddTaglistToTestCase < ActiveRecord::Migration
  def self.up
    add_column :test_cases, :tags_list_string, :string  
    add_column :test_cases, :qatraq_id, :integer  
  end

  def self.down
    remove_column :test_cases, :tags_list_string  
    remove_column :test_cases, :qatraq_id  
  end
end
