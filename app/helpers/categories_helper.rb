module CategoriesHelper
  def renderCategoryTree
    groups = Category.find(:all).group_by {| l | l.parent_id }
    renderCategoryTreeFastDriver(nil,groups,@category)    
  end
  
  def renderCategoryTreeFastDriver(i,groups, curr)
    ret ||= "" if ret.nil?
    ret += '<ul>'
    groups[i].each do |a,v|
      ret += '<li>'
      if curr == a then
         ret += "<b>#{a.name}</b>"
      else
         ret += link_to(a.name, test_cases_path(:category_id => a.id) )              
      end
      ret += renderCategoryTreeFastDriver(a.id,groups,curr)
    end if groups[i]
    ret += '</ul>'
    ret
  end
end
