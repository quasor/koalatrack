class RenameTagsListStringToTags < ActiveRecord::Migration
  def self.up
    rename_column :test_cases, :tags_list_string, :tag
  end

  def self.down
    rename_column :test_cases, :tag, :tags_list_string
  end
end
