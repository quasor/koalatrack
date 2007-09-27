class RemoveOwnerIdFromTestCases < ActiveRecord::Migration
  def self.up
    rename_column :test_cases, :owner_id, :user_id
  end

  def self.down
    rename_column :test_cases, :user_id, :owner_id
  end
end
