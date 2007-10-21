class AddTestCaseVersions4 < ActiveRecord::Migration
  def self.up
    TestCase.drop_versioned_table
    TestCase.reset_column_information
    TestCase.create_versioned_table
  end

  def self.down
    TestCase.drop_versioned_table
  end
end
