class AddCountToCategory < ActiveRecord::Migration
  def self.up
#    add_column :categories, :children_count, :integer, :default => 0
  end

  def self.down
    remove_column :categories, :children_count  
  end
end
