# == Schema Information
# Schema version: 29
#
# Table name: test_case_executions
#
#  id                    :integer(11)   not null, primary key
#  playlist_test_case_id :integer(11)   
#  test_case_id          :integer(11)   
#  test_case_version     :integer(11)   
#  user_id               :integer(11)   
#  result                :integer(11)   
#  bug_id                :string(255)   
#  comment               :text          
#  created_at            :datetime      
#  updated_at            :datetime      
#

class TestCaseExecution < ActiveRecord::Base
  RESULTS = ['Not Run','Passed', 'Failed', 'Blocked', 'Not implemented'] 

  belongs_to :test_case
  belongs_to :user
  belongs_to :playlist_test_case#, :counter_cache => :test_case_executions_count
  
  validates_presence_of :playlist_test_case_id, :test_case_id, :user_id, :result
#TODO  validates_presence_of :bug_id
    
  def bug_url
    (bug_id.split(',').collect { |bug| "<a target=\"_blank\" href=\"http://expediaweb/test/bugs/bug.asp?BugID=#{bug.strip}\">#{bug.strip}</a>"}.join ' ') unless bug_id.nil? || bug_id.blank?
  end
  def siblings
    TestCaseExecution.find_all_by_test_case_id_and_playlist_test_case_id(test_case_id, playlist_test_case_id)
  end
  def to_html
    (result.to_i == 1) ? "<span class='passed'>PASSED</span>" : "<span class='failed'>FAILED</span>"
    
    case result.to_i
    	when 1
    	  "<span class='passed'>PASSED</span>"
    	when 2
    	  "<span class='failed'>FAILED</span>"
    	when 3
    	  "<span class='failed'>BLOCKED</span>"
    	when 4
    	  "<span class='failed'>NOT IMPL</span>"
    	else
    	  ""
    	end
  end
  
  def after_save
    self.update_counter_cache
    super
  end
  def after_destroy
    #self.update_counter_cache
  end
  
  def update_counter_cache
    self.playlist_test_case.last_result = self.result
    self.playlist_test_case.save
  end
  
end
