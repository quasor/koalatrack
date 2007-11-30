class ExecutionSummary < ActiveRecord::Base
  def self.build_summary
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
