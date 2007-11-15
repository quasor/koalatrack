module TestCaseExecutionsHelper
  def result_to_html(result)
    case result
    	when 1
    	  "<span class='passed'>PASSED</span>"
    	when 2
    	  "<span class='failed'>FAILED</span>"
    	when 3
    	  "<span class='failed'>BLOCKED</span>"
    	when 4
    	  "<span class='nyi'>NOT IMPL</span>"
    	else
    	  ""
    	end
  end
  def result_to_html_short(result)
    case result
    	when 1
    	  "<span class='passed'>P</span>"
    	when 2
    	  "<span class='failed'>F</span>"
    	when 3
    	  "<span class='failed'>B</span>"
    	when 4
    	  "<span class='nyi'>N</span>"
    	else
    	  ""
    	end
  end
end
