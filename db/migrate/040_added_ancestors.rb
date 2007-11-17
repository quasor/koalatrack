class AddedAncestors < ActiveRecord::Migration
  def self.up
    TestCase.rebuild_solr_index 300
  end

  def self.down
  end
end
