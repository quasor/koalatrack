module CategoriesHelper
  def renderCategoryTree
    expanded_categories = (session[:expanded_categories] ||= Array.new)
    unless @category.nil?
      if params[:expand]
        expanded_categories.push(@category.id)
      else
        expanded_categories.delete(@category.id)
      end
    end
    Group.find(:all).collect do |group|
	    groups = Rails.cache.fetch("All_categories_as_tree_#{group.id}_#{Category.count}") do 
				group.categories.find(:all).group_by {| l | l.parent_id }
			end
      renderCategoryTreeFastDriver(nil,groups,@category)    
    end
  end
  
  def renderCategoryTreeFastDriver(i,groups, curr)
    ret ||= "" if ret.nil?
    ret += '<ul id="category_tree">'
    groups[i].each do |a,v|
      ret += "<li class='#{'has_children' if a.children.size > 0}_#{ session[:expanded_categories].include?(a.id).to_s}'>"
      if session[:expanded_categories].include?(a.id)
        # + "#category_#{a.id}"
        ret += link_to("#{image_tag( a.children.size > 0 ? 'minus-small.jpg' : 'none-small.jpg', :style => 'margin-left:-14px;') }#{a.name}", test_cases_path(:category_id => a.id, :expand=>false)+"#category_id#{a.id}", :name => "category_id#{a.id}", :class => (curr == a) ? 'selected' : 'unselected' )              
      else
        ret += link_to("#{image_tag( a.children.size > 0 ? 'plus-small.jpg' : 'none-small.jpg', :style => 'margin-left:-14px;') }#{a.name}", test_cases_path(:category_id => a.id, :expand=>true)+"#category_id#{a.id}", :name => "category_id#{a.id}", :class => (curr == a) ? 'selected' : 'unselected' )              
      end
      ret += renderCategoryTreeFastDriver(a.id,groups,curr) if session[:expanded_categories].include?(a.id)
    end if groups[i]
    ret += '</ul>'
    ret
  end

  def categoryTree
    groups = Rails.cache.fetch("All_categories_as_tree#{Category.count}") do 
			Category.find(:all).group_by {| l | l.parent_id }
		end
    categoryTreeFastDriver(nil,groups,@category)    
  end
  
  def categoryTreeFastDriver(i,groups, curr)
    ret ||= [] if ret.nil?
    groups[i].each do |a|
      ret.push a
      ret.push categoryTreeFastDriver(a.id,groups,curr) if session[:expanded_categories].include?(a.id)
    end if groups[i]
    ret
  end

end
