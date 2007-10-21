class AddTestCaseVersions2 < ActiveRecord::Migration
  def self.up
    TestCase.reset_column_information
#    TestCase.drop_versioned_table
    TestCase.create_versioned_table
    TestCase.reset_column_information
  end

  def self.down
    TestCase.drop_versioned_table
  end
end
