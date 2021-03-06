# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_categories(categories, parent_id)
      ret = "<ul>" 
        for category in categories
          if category.parent_id == parent_id
            ret << display_category(category)
          end
        end
      ret << "</ul>" 
    end

  def display_category(category)
    ret = "<li>" 
    ret << link_to(h(category.title), :action => "show", :id => category)
    ret << display_categories(category.children, category.id) if category.children.any?
    ret << "</li>" 
  end
  
  def li_link_to_unless_current(name, options)
    "<span#{" class='current'" if current_page? options}>#{link_to_unless_current name, options}</span>"
  end
  def li_link_to_unless(cond, name, options)
    "<span#{" class='current'" if cond}>#{link_to_unless_current name, options}</span>"
  end
  def link_to_bugs(bugs)
    bugs.collect {|e| e.bug_id.split ',' if e.bug_id}.flatten.compact.uniq.sort.collect { |bug| "<a target=\"_blank\" href=\"http://expediaweb/test/bugs/bug.asp?BugID=#{bug.strip}\">#{bug.strip}</a>"}.join ' '
  end
end
