class AddAdminToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :role_id, :integer, :default => 3
  end

  def self.down
    remove_column :users, :role  
  end
end
