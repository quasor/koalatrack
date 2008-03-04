class AddBugUrLtoGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :bug_url, :string
  end

  def self.down
    remove_column :groups, :bug_url, :string
  end
end
