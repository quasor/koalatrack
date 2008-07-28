class AddTestCaseVersions1 < ActiveRecord::Migration
  def self.up
    TestCase.create_versioned_table
  end

  def self.down
    TestCase.drop_versioned_table
  end
end
