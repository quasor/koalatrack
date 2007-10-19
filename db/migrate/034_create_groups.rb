class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.timestamps 
    end
    add_column :users, :group_id, :integer
    add_column :milestones, :group_id, :integer
    add_column :tag_favorites, :group_id, :integer
    add_column :categories, :group_id, :integer
    
  end

  def self.down
    drop_table :groups
    remove_column :users, :group_id
  end
end
