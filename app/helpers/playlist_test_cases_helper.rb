module PlaylistTestCasesHelper
  def result_to_html(result)
    case result
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
