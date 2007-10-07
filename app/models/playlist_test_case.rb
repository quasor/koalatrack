# == Schema Information
# Schema version: 20
#
# Table name: playlist_test_cases
#
#  id                :integer(11)   not null, primary key
#  playlist_id       :integer(11)   
#  test_case_id      :integer(11)   
#  test_case_version :integer(11)   
#  user_id           :integer(11)   
#  created_at        :datetime      
#  updated_at        :datetime      
#

class PlaylistTestCase < ActiveRecord::Base
  belongs_to :playlist
  belongs_to :user
  belongs_to :test_case
  def test_case_executions
    TestCaseExecution.find_all_by_test_case_id_and_playlist_id(test_case_id, playlist_id)
  end
  validates_uniqueness_of :test_case_id, :scope => :playlist_id
  validates_presence_of :playlist_id, :test_case_id, :user_id
  
  def pass_by!(user_id)
    @version = test_case_version || test_case.version
    @tce = TestCaseExecution.create( :playlist_id => playlist_id, 
      :test_case_id => test_case_id, :user_id => user_id, 
      :test_case_version => @version,:result => 1)                                
  end
end
