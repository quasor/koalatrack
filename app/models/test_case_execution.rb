# == Schema Information
# Schema version: 20
#
# Table name: test_case_executions
#
#  id                :integer(11)   not null, primary key
#  playlist_id       :integer(11)   
#  test_case_id      :integer(11)   
#  test_case_version :integer(11)   
#  user_id           :integer(11)   
#  result            :integer(11)   
#  bug_id            :string(255)   
#  comment           :text          
#  created_at        :datetime      
#  updated_at        :datetime      
#

class TestCaseExecution < ActiveRecord::Base
  belongs_to :test_case
  belongs_to :user
  belongs_to :playlist
  validates_presence_of :playlist_id, :test_case_id, :user_id, :result
    
  def bug_url
    "<a href=\"http://expediaweb/test/bugs/bug.asp?BugID=#{bug_id}\">#{bug_id}</a>"
  end
  def siblings
    TestCaseExecution.find_all_by_test_case_id_and_playlist_id(test_case_id, playlist_id)
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
end
