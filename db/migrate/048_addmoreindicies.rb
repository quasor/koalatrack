class Addmoreindicies < ActiveRecord::Migration
  def self.up
    add_index :test_case_versions, :test_case_id
  end

  def self.down
    remove_index :test_case_versions, :test_case_id
  end
end
