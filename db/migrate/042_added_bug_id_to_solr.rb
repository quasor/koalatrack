class AddedBugIdToSolr < ActiveRecord::Migration
  def self.up
    PlaylistTestCase.rebuild_solr_index 300
  end

  def self.down
  end
end
