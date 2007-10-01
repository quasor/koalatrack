# == Schema Information
# Schema version: 13
#
# Table name: test_case_executions
#
#  id                   :integer(11)   not null, primary key
#  playlist_id          :integer(11)   
#  test_case_id         :integer(11)   
#  test_case_version :integer(11)   
#  user_id              :integer(11)   
#  result               :integer(11)   
#  bug_id               :string(255)   
#  comment              :text          
#  created_at           :datetime      
#  updated_at           :datetime      
#

class TestCaseExecution < ActiveRecord::Base
  belongs_to :test_case
  belongs_to :user
  belongs_to :playlist
  validates_presence_of :playlist_id, :test_case_id, :user_id, :result
    
  def siblings
    TestCaseExecution.find_all_by_test_case_id_and_playlist_id(test_case_id, playlist_id)
  end
end
