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
    "<li#{" class='current'" if current_page? options}>#{link_to_unless_current name, options}"
  end
  def li_link_to_unless(cond, name, options)
    "<li#{" class='current'" if cond}>#{link_to_unless_current name, options}"
  end
  	
end
