class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.integer :parent_id
      t.string :ancestor_cache
      t.timestamps 
    end
  end

  def self.down
    drop_table :categories
  end
end
