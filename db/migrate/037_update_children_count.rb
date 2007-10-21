class UpdateChildrenCount < ActiveRecord::Migration
  def self.up
    @categories = Category.find(:all)
    @categories.collect{ | category | category.update_attributes(:children_count => category.children(true).size) }    
  end

  def self.down
  end
end
