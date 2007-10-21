module CategoriesHelper
  def renderCategoryTree
    expanded_categories = (session[:expanded_categories] ||= Array.new)
    unless @category.nil?
      expanded_categories.push(@category.id) if expanded_categories.delete(@category.id).nil?
    end
    Group.find(:all).collect do |group|
      groups = group.categories.find(:all).group_by {| l | l.parent_id }
      renderCategoryTreeFastDriver(nil,groups,@category)    
    end
  end
  
  def renderCategoryTreeFastDriver(i,groups, curr)
    ret ||= "" if ret.nil?
    ret += '<ul id="category_tree">'
    groups[i].each do |a,v|
      ret += "<li class='#{'has_children' if a.children.size > 0}_#{ session[:expanded_categories].include?(a.id).to_s}'>"
      ret += link_to(a.name, test_cases_path(:category_id => a.id), :class => (curr == a) ? 'selected' : 'unselected' )              
      ret += renderCategoryTreeFastDriver(a.id,groups,curr) if session[:expanded_categories].include?(a.id)
    end if groups[i]
    ret += '</ul>'
    ret
  end

  def categoryTree
    groups = Category.find(:all).group_by {| l | l.parent_id }
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
