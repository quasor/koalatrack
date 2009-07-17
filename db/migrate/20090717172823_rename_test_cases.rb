class RenameTestCases < ActiveRecord::Migration
  def self.up
		rename_table :test_cases, :koala_test_cases
		rename_table :test_case_versions, :koala_test_case_versions
	  rename_column :koala_test_case_versions, :test_case_id, :koala_test_case_id
  end

  def self.down
		rename_table :koala_test_cases, :test_cases
		rename_table :koala_test_case_versions, :test_case_versions
	  rename_column :test_case_versions, :koala_test_case_id, :test_case_id
  end
end
