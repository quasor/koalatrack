# == Schema Information
#
# Table name: test_case_executions
#
#  id                    :integer(4)      not null, primary key
#  playlist_test_case_id :integer(4)
#  test_case_id          :integer(4)
#  test_case_version     :integer(4)
#  user_id               :integer(4)
#  result                :integer(4)
#  bug_id                :string(255)
#  comment               :text
#  created_at            :datetime
#  updated_at            :datetime
#

class TestCaseExecution < ActiveRecord::Base
  RESULTS = ['Not Run','Passed', 'Failed', 'Blocked', 'Not implemented'] 

  belongs_to :test_case, :class_name => "KoalaTestCase"
  belongs_to :user
  belongs_to :playlist_test_case, :counter_cache => :test_case_executions_count
  
  validates_presence_of :playlist_test_case_id, :test_case_id, :test_case_version, :user_id, :result
  #TODO  validates_presence_of :bug_id
    
  def bug_url
    (bug_id.split(',').collect { |bug| "<a target=\"_blank\" href=\"#{user.group.bugurl}#{bug.strip}\">#{bug.strip}</a>"}.join ' ') unless bug_id.nil? || bug_id.blank?
  end
  def siblings
    TestCaseExecution.find_all_by_test_case_id_and_playlist_test_case_id(test_case_id, playlist_test_case_id)
  end
  
  def after_create
    super
    self.update_counter_cache
  end
  def after_destroy
    self.update_counter_cache
  end
  
  def update_counter_cache
    self.playlist_test_case.last_result = self.result
    self.playlist_test_case.save!
  end
    
end
