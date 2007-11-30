# == Schema Information
# Schema version: 38
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
  belongs_to :playlist_test_case, :counter_cache => :test_case_executions_count
  
  validates_presence_of :playlist_test_case_id, :test_case_id, :test_case_version, :user_id, :result
#TODO  validates_presence_of :bug_id
    
  def bug_url
    (bug_id.split(',').collect { |bug| "<a target=\"_blank\" href=\"http://expediaweb/test/bugs/bug.asp?BugID=#{bug.strip}\">#{bug.strip}</a>"}.join ' ') unless bug_id.nil? || bug_id.blank?
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
  
  def self.update_summary
    d1 = TestCaseExecution.find(:first).created_at.to_date
    d2 = Date.today
    for date in (d1..d2) do
    @sql = <<-SQL
    REPLACE INTO execution_summaries 
    	SELECT '#{date.to_s}' as date, d.id as playlist_id, 
    	       sum(case when result = 1 then 1 else 0 end) as passed,
    	       sum(case when result = 2 then 1 else 0 end) as failed,
    	      sum(case when result = 3 then 1 else 0 end) as blocked,
    	      sum(case when result = 4 then 1 else 0 end) as nyied
    	  FROM test_case_executions as a
    	  inner join
    	       (SELECT DATE(created_at) as created_at_date, playlist_test_case_id, MAX(id) as IDMax
    	        FROM test_case_executions
    	        GROUP BY DATE(created_at), playlist_test_case_id) AS B 
    		on DATE(a.created_at) = B.created_at_date and a.playlist_test_case_id = B.playlist_test_case_id

    	  inner join
    	       playlist_test_cases c on a.playlist_test_case_id = c.id
    	  inner join
    	       playlists d on c.playlist_id = d.id
    	WHERE
    	a.created_at < '#{date.to_s}'
    	GROUP BY d.title
    	ORDER BY d.id,  d.title
      SQL

      TestCaseExecution.connection.execute @sql
    end
  end
  
end
