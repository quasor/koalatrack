require File.dirname(__FILE__) + '/abstract_unit'
require File.dirname(__FILE__) + '/fixtures/mixin'
require 'pp'

class MixinNestedSetTest < Test::Unit::TestCase
  fixtures :mixins
    
  ##########################################
  # HIGH LEVEL TESTS
  ##########################################
  def test_mixing_in_methods
    ns = NestedSet.new
    assert(ns.respond_to?(:all_children)) # test a random method
    
    check_method_mixins(ns)
    check_class_method_mixins(NestedSet)
  end
  
  def check_method_mixins(obj)
    [:<=>, :all_children, :ancestors, :before_create, :before_destroy, :check_full_tree, :children, 
    :all_children_count, :full_set, :leaves, :leaves_count, :lineage_col_name, :level, :move_to_child_of, 
    :move_to_left_of, :move_to_right_of, :move_to_root, :parent, :parent_col_name, :renumber_full_tree, 
    :root, :roots, :self_and_ancestors, :self_and_siblings, 
    :siblings].each { |symbol| assert(obj.respond_to?(symbol), "failed to respond to #{symbol}") }
  end
  
  def check_class_method_mixins(klass)
    [:root, :roots, :check_all, 
    :renumber_all].each { |symbol| assert(klass.respond_to?(symbol), "failed to respond to #{symbol}") }
  end
  
  def test_string_scope
    ns = NestedSet.new
    assert_equal("mixins.root_id IS NULL", ns.scope_condition)
    
    ns = NestedSetWithStringScope.new
    ns.root_id = 1
    assert_equal("mixins.root_id = 1", ns.scope_condition)
    ns.root_id = 42
    assert_equal("mixins.root_id = 42", ns.scope_condition)
    check_method_mixins ns
  end
  
  def test_symbol_scope
    ns = NestedSetWithSymbolScope.new
    ns.root_id = 1
    assert_equal("mixins.root_id = 1", ns.scope_condition)
    ns.root_id = 42
    assert_equal("mixins.root_id = 42", ns.scope_condition)
    check_method_mixins ns
  end
  
  def test_protected_attributes
    ns = NestedSet.new(:lineage => "foo")
    assert_equal nil, ns.lineage
  end
    
  def test_really_protected_attributes
    ns = NestedSet.new
    assert_raise(ActiveRecord::ActiveRecordError) {ns.lineage = "1"}
  end
  
  ###############
  
  def test_basic_renumber_check
    ns = set2(1)
    ns.renumber_full_tree
    assert_nothing_raised {ns.reload.check_full_tree}
  end
  
  ##########################################
  # CLASS METHOD TESTS
  ##########################################
  def test_class_root
    NestedSetWithStringScope.roots.each {|r| r.destroy unless r.id == 4001}
    assert_equal([NestedSetWithStringScope.find(4001)], NestedSetWithStringScope.roots)
    NestedSetWithStringScope.find(4001).destroy
    assert_equal(nil, NestedSetWithStringScope.root)
    ns = NestedSetWithStringScope.create(:root_id => 2)
    assert_equal(ns, NestedSetWithStringScope.root)
  end
  
  def test_class_root_again
    NestedSetWithStringScope.roots.each {|r| r.destroy unless r.id == 101}
    assert_equal(NestedSetWithStringScope.find(101), NestedSetWithStringScope.root)
  end
  
  def test_class_roots
    assert_equal(2, NestedSetWithStringScope.roots.size)
    assert_equal(10, NestedSet.roots.size) # May change if STI behavior changes
  end
  
  def test_check_all_1
    assert_nothing_raised {NestedSetWithStringScope.check_all}
    NestedSetWithStringScope.update_all("lineage = 'foo'", "id = 103")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
  end
  
  def test_check_all_2
    NestedSetWithStringScope.update_all("lineage = concat(lineage, '.0')", "lineage LIKE '0.1.%' AND root_id = 101")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all} 
  end
  
  def test_check_all_3
    NestedSetWithStringScope.update_all("lineage = concat(lineage, '.')", "lineage LIKE '0.1.%' AND root_id = 101")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all} 
  end
  
# # no v-roots yet
# def test_check_all_4
#   ns = NestedSetWithStringScope.create(:root_id => 101) # virtual root
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
#   NestedSetWithStringScope.update_all("rgt = rgt + 2, lineage = lineage + 2", "id = #{ns.id}") # create a gap between virtual roots
#   assert_nothing_raised {ns.check_subtree}
#   assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all} 
# end
  
  def test_renumber_all
    NestedSetWithStringScope.update_all("lineage = NULL")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
    NestedSetWithStringScope.renumber_all    
    assert_nothing_raised(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
    NestedSetWithStringScope.update_all("lineage = '0'")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
    NestedSetWithStringScope.renumber_all    
    assert_nothing_raised(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
  end
  
  def test_sql_for
    assert_equal("1 != 1", Category.sql_for([]))
    c = Category.new
    assert_equal("1 != 1", Category.sql_for(c))
    assert_equal("1 != 1", Category.sql_for([c]))
    c.save
    assert_equal("((mixins.lineage LIKE '0.%'))", Category.sql_for(c))
    assert_equal("((mixins.lineage LIKE '0.%'))", Category.sql_for([c]))
    assert_equal("((mixins.lineage LIKE '0.%'))", NestedSetWithStringScope.sql_for(101))
    assert_equal("((mixins.lineage LIKE '0.%') OR (mixins.lineage LIKE '0.1.%'))", NestedSetWithStringScope.sql_for([101, set2(3)]))
    assert_equal("((mixins.lineage LIKE '0.1.0.%') OR (mixins.lineage LIKE '0.1.1.%') OR (mixins.lineage LIKE '0.1.2.%'))", NestedSetWithStringScope.sql_for(set2(3).children))
  end
  
  
  ##########################################
  # CALLBACK TESTS
  ##########################################
  # If we change behavior of virtual roots, this test may change
  def test_before_create
    ns = NestedSetWithSymbolScope.create(:root_id => 1234)
    assert_equal("0", ns.lineage)
    
# no v-roots yet   
# no v-roots yet   ns = NestedSetWithSymbolScope.create(:root_id => 1234)
# no v-roots yet   assert_equal(3, ns.lineage)
# no v-roots yet   assert_equal(4, ns.rgt)
  end
  
  # test the callbacks that trigger updates of lineage/rgt values after save  
  def test_after_save
    ns = set2(9)
    ns.parent=(set2(1))
    ns.save
    assert_equal(ns, set2(1).children.last)
    assert_nothing_raised(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
  end
    
  
# # test pruning a branch. only works if we allow the deletion of nodes with children
# def test_destroy
#   big_tree = NestedSetWithStringScope.find(4001)
#   
#   # Make sure we have the right one
#   assert_equal(3, big_tree.children.length)
#   assert_equal(10, big_tree.full_set.length)
#   
#   NestedSetWithStringScope.find(4005).destroy
#
#   big_tree = NestedSetWithStringScope.find(4001)
#   
#   assert_equal(7, big_tree.full_set.length)
#   assert_equal(2, big_tree.children.length)
#   
#   assert_equal(1, NestedSetWithStringScope.find(4001).lineage)
#   assert_equal(2, NestedSetWithStringScope.find(4002).lineage)
#   assert_equal(3, NestedSetWithStringScope.find(4003).lineage)
#   assert_equal(4, NestedSetWithStringScope.find(4003).rgt)
#   assert_equal(5, NestedSetWithStringScope.find(4004).lineage)
#   assert_equal(6, NestedSetWithStringScope.find(4004).rgt)
#   assert_equal(7, NestedSetWithStringScope.find(4002).rgt)
#   assert_equal(8, NestedSetWithStringScope.find(4008).lineage)
#   assert_equal(9, NestedSetWithStringScope.find(4009).lineage)
#   assert_equal(10, NestedSetWithStringScope.find(4009).rgt)
#   assert_equal(11, NestedSetWithStringScope.find(4010).lineage)
#   assert_equal(12, NestedSetWithStringScope.find(4010).rgt)
#   assert_equal(13, NestedSetWithStringScope.find(4008).rgt)
#   assert_equal(14, NestedSetWithStringScope.find(4001).rgt)
# end
# 
# def test_destroy_2
#   assert_nothing_raised {set2(1).check_subtree}
#   assert set2(10).destroy    
#   assert_nothing_raised {set2(1).reload.check_subtree}
#   assert set2(9).children.empty?
#   assert set2(9).destroy
#   assert_equal 15, set2(4).rgt
#   assert_nothing_raised {set2(1).reload.check_subtree}
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_destroy_3
#   assert set2(3).destroy
#   assert_equal(2, set2(1).children.size)
#   assert_equal(0, NestedSetWithStringScope.find(:all, :conditions => "id > 104 and id < 108").size)
#   assert_equal(6, set2(1).full_set.size)
#   assert_equal(3, set2(2).rgt)
#   assert_equal(4, set2(4).lineage)
#   assert_equal(12, set2(1).rgt)
#   assert_nothing_raised {set2(1).check_subtree}
# end
# 
# def test_destroy_root
#   NestedSetWithStringScope.find(4001).destroy
#   assert_equal(0, NestedSetWithStringScope.count(:conditions => "root_id = 42"))
# end            
# 
# def test_destroy_dependent
#   NestedSetWithStringScope.acts_as_nested_set_options[:dependent] = :destroy
#   
#   big_tree = NestedSetWithStringScope.find(4001)
#   
#   # Make sure we have the right one
#   assert_equal(3, big_tree.children.length)
#   assert_equal(10, big_tree.full_set.length)
#   
#   NestedSetWithStringScope.find(4005).destroy
#
#   big_tree = NestedSetWithStringScope.find(4001)
#   
#   assert_equal(7, big_tree.full_set.length)
#   assert_equal(2, big_tree.children.length)
#   
#   assert_equal(1, NestedSetWithStringScope.find(4001).lineage)
#   assert_equal(2, NestedSetWithStringScope.find(4002).lineage)
#   assert_equal(3, NestedSetWithStringScope.find(4003).lineage)
#   assert_equal(4, NestedSetWithStringScope.find(4003).rgt)
#   assert_equal(5, NestedSetWithStringScope.find(4004).lineage)
#   assert_equal(6, NestedSetWithStringScope.find(4004).rgt)
#   assert_equal(7, NestedSetWithStringScope.find(4002).rgt)
#   assert_equal(8, NestedSetWithStringScope.find(4008).lineage)
#   assert_equal(9, NestedSetWithStringScope.find(4009).lineage)
#   assert_equal(10, NestedSetWithStringScope.find(4009).rgt)
#   assert_equal(11, NestedSetWithStringScope.find(4010).lineage)
#   assert_equal(12, NestedSetWithStringScope.find(4010).rgt)
#   assert_equal(13, NestedSetWithStringScope.find(4008).rgt)
#   assert_equal(14, NestedSetWithStringScope.find(4001).rgt)  
# end
# 
# ##########################################
# # ACTIVERECORD ASSOCIATION TESTS
# ##########################################
# # The following are tests of the attribute-altering methods 
# # added by belongs_to and has_many.
# 
# def test_parent=
#   c1, c2 = Category.create, Category.create
#   c1.parent=(c2)
#   c1.save
#   assert_equal(nil, c2.parent)
#   assert_equal(c2, c1.parent)
#   assert_equal([c1], c2.children)
#   assert_nothing_raised {Category.check_all}
#   c1.parent=(nil)
#   assert c1.save
#   assert_equal([], c2.reload.children)
#   assert_equal(nil, c1.parent)
#   assert_nothing_raised {Category.check_all}   
# end
# 
# def test_parent_id=
#   ns = set2(9)
#   ns.parent_id = 101
#   assert ns.save
#   assert_equal(ns, set2(1).children.last)
#   ns2 = set2(4)
#   ns2.parent_id = nil
#   ns2.save
#   assert_equal(ns2, ns.roots.last)
#   ns3 = set2(1)
#   ns3.parent_id = 104
#   ns3.save
#   assert_equal([set2(4)], ns.roots)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}   
# end
# 
# def test_build_parent
#   c1 = Category.create
#   c1.build_parent
#   assert c1.save
#   assert_equal(2, Category.count)
#   assert_equal([c1], c1.parent.children)
#   assert_nothing_raised {Category.check_all}
#   
#   ns = set2(1)
#   ns.build_parent(:root_id => 101)
#   assert ns.save
#   assert_equal([ns.parent], ns.roots)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}   
# end
# 
# def test_create_parent
#   c1 = Category.create
#   c1.create_parent
#   assert c1.save # this is needed to trigger the move
#   assert_equal(2, Category.count)
#   assert_equal([c1], c1.parent.children)
#   assert_nothing_raised {Category.check_all}
#   
#   ns = set2(1)
#   ns.create_parent(:root_id => 101)
#   assert ns.save  # this is needed to trigger the move
#   assert_equal([ns.parent], ns.roots)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}   
# end
#
# def test_children_push
#   c1, c2, c3 = Category.create, Category.create, Category.create
#   c2.children << c1 << c3
#   c2.save
#   assert_equal(c2, c3.parent)
#   assert_equal([c1, c3], c2.children(true)) # 'true' forces reload
#   assert_nothing_raised {Category.check_all}
#   
#   ns = set2(2)
#   ns.children << set2(7) << set2(8) << set2(9)
#   ns.save
#   ns.reload ## the left/right values don't get refreshed in the save
#   assert_equal([], set2(4).children)
#   assert_equal(4, ns.all_children.size)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}       
# end
# 
# def test_children_delete
#   set2(4).children.delete(set2(9))
#   assert_equal(1, set2(4).all_children.size)
#   assert_equal(nil, NestedSetWithStringScope.find(:first, :conditions => "id = 109"))
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_children=
#   c1, c2, c3 = Category.create, Category.create, Category.create
#   c2.children = [c1, c3]
#   c2.save
#   assert_equal(c2, c3.parent)
#   assert_equal([c1, c3], c2.children(true)) # 'true' forces reload
#   assert_nothing_raised {Category.check_all}
#   
#   ns = set2(2)
#   ns.children = [set2(7), set2(8), set2(9)]
#   ns.save
#   ns.reload ## the left/right values don't get refreshed in the save
#   assert_equal([], set2(4).children)
#   assert_equal(4, ns.all_children.size)
#   
#   ns2 = set2(3)
#   ns2.children = [set2(7), set2(8), set2(9)]
#   ns2.save
#   assert_equal(7, set2(1).all_children.size) # the two existing children of set2(3) were deleted
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_child_ids=
#   c1, c2, c3 = Category.create, Category.create, Category.create
#   c2.child_ids = [c1.id, c3.id]
#   c2.save
#   assert_equal(c2, c3.reload.parent)
#   assert_equal([c1, c3], c2.children(true)) # 'true' forces reload
#   assert_nothing_raised {Category.check_all}
#   
#   ns = set2(2)
#   ns.child_ids = [107, 108, 109]
#   ns.save
#   ns.reload ## the left/right values don't get refreshed in the save
#   assert_equal([], set2(4).children)
#   assert_equal(4, ns.all_children.size)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_children_clear
#   set2(2).children.clear
#   set2(4).children.clear
#   assert_equal(6, set2(1).all_children.size)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_children_build
#   c1 = Category.create
#   c2 = c1.children.build
#   c3 = c1.children.build
#   assert c2.save
#   assert c3.save
#   c1.reload
#   assert_equal(3, Category.count)
#   assert_equal(2, c1.children.size)
#   assert_equal(2, c1.all_children_count)
#   assert_nothing_raised {Category.check_all}
#   
#   ns1, ns2 = set2(1), set2(2)
#   new1, new2, new3 = ns2.children.build(:root_id => 101), ns2.children.build(:root_id => 101), ns1.children.build(:root_id => 101)
#   new1.save; new2.save; new3.save
#   assert_equal(2, set2(2).children.size)
#   assert_equal(12, set2(1).all_children_count)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_children_create
#   c1 = Category.create
#   c1.children.create
#   c1.children.create
#   c1.reload
#   assert_equal(2, c1.all_children_count)
#   assert_equal(2, c1.children.size)
#   assert_equal(3, Category.count)
#   assert_nothing_raised {Category.check_all}
#   
#   set2(2).children.create(:root_id => 101)
#   set2(2).children.create(:root_id => 101)
#   set2(1).children.create(:root_id => 101)
#   assert_equal(12, set2(1).all_children_count)
#   assert_equal(23, NestedSetWithStringScope.count)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# 
# ##########################################
# # QUERY METHOD TESTS
# ##########################################
  def set(id) NestedSet.find(3000 + id) end # helper method
  
  def set2(id) NestedSetWithStringScope.find(100 + id) end # helper method
    
# # Test the <=> method implicitly
# def test_comparison
#   ar = NestedSetWithStringScope.find(:all, :conditions => "root_id = 42", :order => "lineage")
#   ar2 = NestedSetWithStringScope.find(:all, :conditions => "root_id = 42", :order => "rgt")
#   assert_not_equal(ar, ar2)
#   assert_equal(ar, ar2.sort)
# end
# 
# def test_root
#   assert_equal(NestedSetWithStringScope.find(4001), NestedSetWithStringScope.find(4007).root)
#   assert_equal(set2(1), set2(8).root)
#   assert_equal(set2(1), set2(1).root)
#   # test virtual roots
#   c1, c2, c3 = Category.create, Category.create, Category.create
#   c3.move_to_child_of(c2)
#   assert_equal(c2, c3.root)
# end
# 
# def test_roots
#   assert_equal([set2(1)], set2(8).roots)
#   assert_equal([set2(1)], set2(1).roots)
#   assert_equal(NestedSet.find(:all, :conditions => "id > 3000 AND id < 4000").size, set(1).roots.size)
# end
# 
# def test_parent
#   ns = NestedSetWithStringScope.create(:root_id => 45)
#   assert_equal(nil, ns.parent)
#   assert ns.save
#   assert_equal(nil, ns.parent)
#   assert_equal(set2(1), set2(2).parent)
#   assert_equal(set2(3), set2(7).parent)
# end
# 
# def test_ancestors
#   assert_equal([], set2(1).ancestors)
#   assert_equal([set2(1), set2(4), set2(9)], set2(10).ancestors)
# end
# 
# def test_self_and_ancestors
#   assert_equal([set2(1)], set2(1).self_and_ancestors)
#   assert_equal([set2(1), set2(4), set2(8)], set2(8).self_and_ancestors)
#   assert_equal([set2(1), set2(4), set2(9), set2(10)], set2(10).self_and_ancestors)
# end
# 
# def test_siblings
#   assert_equal([], set2(1).siblings)
#   assert_equal([set2(2), set2(4)], set2(3).siblings)
# end
# 
# def test_first_sibling
#   assert set2(2).first_sibling?
#   assert_equal(set2(2), set2(2).first_sibling)
#   assert_equal(set2(2), set2(3).first_sibling)
#   assert_equal(set2(2), set2(4).first_sibling)
# end
# 
# def test_last_sibling
#   assert set2(4).last_sibling?
#   assert_equal(set2(4), set2(2).last_sibling)
#   assert_equal(set2(4), set2(3).last_sibling)
#   assert_equal(set2(4), set2(4).last_sibling)
# end
# 
# def test_previous_siblings
#   assert_equal([], set2(2).previous_siblings)
#   assert_equal([set2(2)], set2(3).previous_siblings)
#   assert_equal([set2(3), set2(2)], set2(4).previous_siblings)
# end
# 
# def test_previous_sibling
#   assert_equal(nil, set2(2).previous_sibling)
#   assert_equal(set2(2), set2(3).previous_sibling)
#   assert_equal(set2(3), set2(4).previous_sibling)
#   assert_equal([set2(3), set2(2)], set2(4).previous_sibling(2))
# end
# 
# def test_next_siblings
#   assert_equal([], set2(4).next_siblings)
#   assert_equal([set2(4)], set2(3).next_siblings)
#   assert_equal([set2(3), set2(4)], set2(2).next_siblings)
# end
# 
# def test_next_sibling
#   assert_equal(nil, set2(4).next_sibling)
#   assert_equal(set2(4), set2(3).next_sibling)
#   assert_equal(set2(3), set2(2).next_sibling)
#   assert_equal([set2(3), set2(4)], set2(2).next_sibling(2))
# end
# 
# def test_self_and_siblings
#   assert_equal([set2(1)], set2(1).self_and_siblings)
#   assert_equal([set2(2), set2(3), set2(4)], set2(3).self_and_siblings)    
# end
# 
# def test_level
#   assert_equal(0, set2(1).level)
#   assert_equal(1, set2(3).level)
#   assert_equal(3, set2(10).level)
# end
# 
# def test_all_children_count
#   assert_equal(0, set2(10).all_children_count)
#   assert_equal(1, set2(3).level)
#   assert_equal(3, set2(10).level)    
# end
# 
# def test_full_set
#   assert_equal(NestedSetWithStringScope.find(:all, :conditions => "root_id = 101", :order => "lineage"), set2(1).full_set)
#   new_ns = NestedSetWithStringScope.new(:root_id => 101)
#   assert_equal([new_ns], new_ns.full_set)
#   assert_equal([set2(4), set2(8), set2(9), set2(10)], set2(4).full_set)
#   assert_equal([set2(2)], set2(2).full_set)
#   assert_equal([set2(2)], set2(2).full_set(:exclude => nil))
#   assert_equal([set2(2)], set2(2).full_set(:exclude => []))
#   assert_equal([], set2(1).full_set(:exclude => 101))
#   assert_equal([], set2(1).full_set(:exclude => set2(1)))
#   ns = NestedSetWithStringScope.create(:root_id => 234)
#   assert_equal([], ns.full_set(:exclude => ns))
#   assert_equal([set2(4), set2(8), set2(9)], set2(4).full_set(:exclude => set2(10)))
#   assert_equal([set2(4), set2(8)], set2(4).full_set(:exclude => set2(9))) 
# end
#   
# def test_all_children
#   assert_equal(NestedSetWithStringScope.find(:all, :conditions => "root_id = 101 AND id > 101", :order => "lineage"), set2(1).all_children)
#   assert_equal([], NestedSetWithStringScope.new(:root_id => 101).all_children)
#   assert_equal([set2(8), set2(9), set2(10)], set2(4).all_children)
#   assert_equal([set2(8), set2(9)], set2(4).all_children(:exclude => set2(10)))
#   assert_equal([set2(8)], set2(4).all_children(:exclude => set2(9)))
#   assert_equal([set2(2), set2(4), set2(8)], set2(1).all_children(:exclude => [set2(9), 103]))
#   assert_equal([set2(2), set2(4), set2(8)], set2(1).all_children(:exclude => [set2(9), 103, 106]))
# end
# 
# def test_children
#   assert_equal([], set2(10).children) 
#   assert_equal([], set(1).children) 
#   assert_equal([set2(2), set2(3), set2(4)], set2(1).children) 
#   assert_equal([set2(5), set2(6), set2(7)], set2(3).children) 
#   assert_equal([NestedSetWithStringScope.find(4006), NestedSetWithStringScope.find(4007)], NestedSetWithStringScope.find(4005).children) 
# end
# 
# def test_leaves
#   assert_equal([set2(10)], set2(9).leaves)
#   assert_equal([set2(10)], set2(10).leaves)
#   assert_equal([set2(2), set2(5), set2(6), set2(7), set2(8), set2(10)], set2(1).leaves)
# end
# 
# def test_leaves_count
#   assert_equal(1, set2(10).leaves_count)
#   assert_equal(1, set2(9).leaves_count)
#   assert_equal(6, set2(1).leaves_count)
# end
#
# ##########################################
# # CASTING RESULT TESTS
# ##########################################
# 
# def test_recurse_result_set
#   result = []
#   NestedSetWithStringScope.recurse_result_set(set2(1).full_set) do |node, level|
#     result << [level, node.id]
#   end
#   expected = [[0, 101], [1, 102], [1, 103], [2, 105], [2, 106], [2, 107], [1, 104], [2, 108], [2, 109], [3, 110]]
#   assert_equal expected, result
# end
# 
# def test_disjointed_result_set
#   result_set = set2(1).full_set(:conditions => { :type => 'NestedSetWithStringScope' })
#   result = []
#   NestedSetWithStringScope.recurse_result_set(result_set) do |node, level|
#     result << [level, node.id]
#   end
#   expected = [[0, 102], [0, 104], [0, 105], [0, 106], [0, 107], [0, 110]]
#   assert_equal expected, result
# end
# 
# def test_result_to_array
#   result = NestedSetWithStringScope.result_to_array(set2(1).full_set) do |node, level|
#     { :id => node.id, :level => level }
#   end
#   expected = [{:level=>0, :children=>[{:level=>1, :id=>102}, {:level=>1, 
#     :children=>[{:level=>2, :id=>105}, {:level=>2, :id=>106}, {:level=>2, :id=>107}], :id=>103}, {:level=>1, 
#     :children=>[{:level=>2, :id=>108}, {:level=>2, :children=>[{:level=>3, :id=>110}], :id=>109}], :id=>104}], :id=>101}]
#   assert_equal expected, result
# end
# 
# def test_disjointed_result_to_array
#   result_set = set2(1).full_set(:conditions => { :type => 'NestedSetWithStringScope' })
#   result = NestedSetWithStringScope.result_to_array(result_set) do |node, level|
#     { :id => node.id, :level => level }
#   end
#   expected = [{:level=>0, :id=>102}, {:level=>0, :id=>104}, {:level=>0, :id=>105}, {:level=>0, :id=>106}, {:level=>0, :id=>107}, {:level=>0, :id=>110}]
#   assert_equal expected, result
# end
# 
# def test_result_to_array_flat
#   result = NestedSetWithStringScope.result_to_array(set2(1).full_set, :nested => false) do |node, level|
#     { :id => node.id, :level => level }
#   end
#   expected = [{:level=>0, :id=>101}, {:level=>0, :id=>103}, {:level=>0, :id=>106}, {:level=>0, :id=>104}, {:level=>0, :id=>109}, 
#     {:level=>0, :id=>102}, {:level=>0, :id=>105}, {:level=>0, :id=>107}, {:level=>0, :id=>108}, {:level=>0, :id=>110}]
#   assert_equal expected, result
# end
# 
# def test_result_to_xml
#   result = NestedSetWithStringScope.result_to_xml(set2(3).full_set, :record => 'node', :dasherize => false, :only => [:id]) do |options, subnode|
#      options[:builder].tag!('type', subnode[:type])
#   end
#   expected = '<?xml version="1.0" encoding="UTF-8"?>
#nodes>
# <node>
#   <id type="integer">103</id>
#   <type>NS2</type>
#   <children>
#     <node>
#       <id type="integer">105</id>
#       <type>NestedSetWithStringScope</type>
#       <children>
#       </children>
#     </node>
#     <node>
#       <id type="integer">106</id>
#       <type>NestedSetWithStringScope</type>
#       <children>
#       </children>
#     </node>
#     <node>
#       <id type="integer">107</id>
#       <type>NestedSetWithStringScope</type>
#       <children>
#       </children>
#     </node>
#   </children>
# </node>
#/nodes>'
#   assert_equal expected, result.strip
# end
# 
# def test_disjointed_result_to_xml
#   result_set = set2(1).full_set(:conditions => ['type IN(?)', ['NestedSetWithStringScope', 'NS2']])
#   result = NestedSetWithStringScope.result_to_xml(result_set, :only => [:id])
#   # note how nesting is preserved where possible; this is not always what you want though, 
#   # so you can force a flattened set with :nested => false instead (see below)
#   expected = '<?xml version="1.0" encoding="UTF-8"?>
#nodes>
# <nested-set-with-string-scope>
#   <id type="integer">102</id>
#   <children>
#   </children>
# </nested-set-with-string-scope>
# <ns2>
#   <id type="integer">103</id>
#   <children>
#     <nested-set-with-string-scope>
#       <id type="integer">105</id>
#       <children>
#       </children>
#     </nested-set-with-string-scope>
#     <nested-set-with-string-scope>
#       <id type="integer">106</id>
#       <children>
#       </children>
#     </nested-set-with-string-scope>
#     <nested-set-with-string-scope>
#       <id type="integer">107</id>
#       <children>
#       </children>
#     </nested-set-with-string-scope>
#   </children>
# </ns2>
# <nested-set-with-string-scope>
#   <id type="integer">104</id>
#   <children>
#     <ns2>
#       <id type="integer">108</id>
#       <children>
#       </children>
#     </ns2>
#   </children>
# </nested-set-with-string-scope>
#/nodes>'
#   assert_equal expected, result.strip
# end
# 
# def test_result_to_xml_flat
#   result = NestedSetWithStringScope.result_to_xml(set2(3).full_set, :record => 'node', :dasherize => false, :only => [:id], :nested => false)
#   expected = '<?xml version="1.0" encoding="UTF-8"?>
#nodes>
# <node>
#   <id type="integer">103</id>
# </node>
# <node>
#   <id type="integer">105</id>
# </node>
# <node>
#   <id type="integer">106</id>
# </node>
# <node>
#   <id type="integer">107</id>
# </node>
#/nodes>'
#   assert_equal expected, result.strip
# end
# 
# ##########################################
# # WITH_SCOPE QUERY TESTS
# ##########################################
# 
# def test_filtered_full_set
#   result_set = set2(1).full_set(:conditions => { :type => 'NestedSetWithStringScope' })
#   assert_equal [102, 105, 106, 107, 104, 110], result_set.map(&:id)
# end
# 
# def test_reverse_result_set
#   result_set = set2(1).full_set(:reverse => true)  
#   assert_equal [101, 104, 109, 110, 108, 103, 107, 106, 105, 102], result_set.map(&:id)
#   # NestedSetWithStringScope.recurse_result_set(result_set) { |node, level| puts "#{'--' * level}#{node.id}" }
# end
# 
# def test_reordered_full_set
#   result_set = set2(1).full_set(:order => 'id DESC')
#   assert_equal [110, 109, 108, 107, 106, 105, 104, 103, 102, 101], result_set.map(&:id)
# end
# 
# def test_filtered_siblings
#   node = set2(2)
#   result_set = node.siblings(:conditions => { :type => node[:type] })
#   assert_equal [104], result_set.map(&:id)
# end
# 
# def test_include_option_with_full_set
#   result_set = set2(3).full_set(:include => :parent_node)
#   assert_equal [[103, 101], [105, 103], [106, 103], [107, 103]], result_set.map { |n| [n.id, n.parent_node.id] }
# end
# 
# ##########################################
# # INDEX-CHECKING METHOD TESTS
# ##########################################
# def test_check_subtree
#   root = set2(1)
#   assert_nothing_raised {root.check_subtree}
#   # need to use update_all to get around attr_protected
#   NestedSetWithStringScope.update_all("rgt = #{root.lineage + 1}", "id = #{root.id}")
#   assert_raise(ActiveRecord::ActiveRecordError) {root.reload.check_subtree}
#   assert_nothing_raised {set2(4).check_subtree}
#   NestedSetWithStringScope.update_all("lineage = 17", "id = 110")
#   assert_raise(ActiveRecord::ActiveRecordError) {set2(4).reload.check_subtree}
#   NestedSetWithStringScope.update_all("rgt = 18", "id = 110")
#   assert_nothing_raised {set2(10).check_subtree}
#   NestedSetWithStringScope.update_all("rgt = NULL", "id = 4002")
#   assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.find(4001).reload.check_subtree}
#   # this method receives lots of additional testing through tests of check_full_tree and check_all
# end
# 
# def test_check_full_tree
#   assert_nothing_raised {set2(1).check_full_tree}
#   assert_nothing_raised {NestedSetWithStringScope.find(4006).check_full_tree}
#   NestedSetWithStringScope.update_all("rgt = NULL", "id = 4002")
#   assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.find(4006).check_full_tree}
#   NestedSetWithStringScope.update_all("rgt = 0", "id = 4001")
#   assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.find(4006).check_full_tree}
#   NestedSetWithStringScope.update_all("rgt = rgt + 1", "id > 101")
#   NestedSetWithStringScope.update_all("lineage = lineage + 1", "id > 101")
#   assert_raise(ActiveRecord::ActiveRecordError) {set2(4).check_full_tree}
# end
# 
# def test_check_full_tree_orphan
#   assert_raise(ActiveRecord::RecordNotFound) {NestedSetWithStringScope.find(99)} # make sure ID 99 doesn't exist
#   ns = NestedSetWithStringScope.create(:root_id => 101)
#   NestedSetWithStringScope.update_all("parent_id = 99", "id = #{ns.id}")
#   assert_raise(ActiveRecord::ActiveRecordError) {set2(3).check_full_tree}
# end
# 
# def test_check_full_tree_endless_loop
#   ns = NestedSetWithStringScope.create(:root_id => 101)
#   NestedSetWithStringScope.update_all("parent_id = #{ns.id}", "id = #{ns.id}")
#   assert_raise(ActiveRecord::ActiveRecordError) {set2(6).check_full_tree}
# end
# 
# def test_check_full_tree_virtual_roots
#   a = Category.create    
#   b = Category.create
#   
#   assert_nothing_raised {a.check_full_tree}
#   Category.update_all("rgt = rgt + 2, lineage = lineage + 2", "id = #{b.id}") # create a gap between virtual roots
#   assert_raise(ActiveRecord::ActiveRecordError) {a.check_full_tree}
# end
# 
# # see also the tests of check_all under 'class method tests'
#   
# ##########################################
# # INDEX-ALTERING (UPDATE) METHOD TESTS
# ##########################################
# def test_move_to_left_of # this method undergoes additional testing elsewhere
#   set2(2).move_to_left_of(set2(3)) # should cause no change
#   assert_equal(2, set2(2).lineage)
#   assert_equal(4, set2(3).lineage)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
#   set2(3).move_to_left_of(set2(2))
#   assert_equal(9, set2(3).rgt)
#   set2(2).move_to_left_of(set2(3))
#   assert_equal(2, set2(2).lineage)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
#   set2(3).move_to_left_of(102) # pass an ID instead
#   assert_equal(2, set2(3).lineage)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_move_to_right_of # this method undergoes additional testing elsewhere
#   set2(3).move_to_right_of(set2(2)) # should cause no change
#   set2(4).move_to_right_of(set2(3)) # should cause no change
#   assert_equal(11, set2(3).rgt)
#   assert_equal(19, set2(4).rgt)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
#   set2(3).move_to_right_of(set2(4))
#   assert_equal(19, set2(3).rgt)
#   set2(4).move_to_right_of(set2(3))
#   assert_equal(4, set2(3).lineage)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
#   set2(3).move_to_right_of(104) # pass an ID instead
#   assert_equal(4, set2(4).lineage)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_adding_children
#   set(2).move_to_child_of(set(1))
#   
#   # Did we maintain adding the parent_ids?
#   assert_equal(nil, set(1).parent)
#   assert(set(2).parent)
#   assert(set(2).parent_id == set(1).id)
#   
#   # Check boundaries
#   assert_equal(set(1).lineage, 1)
#   assert_equal(set(2).lineage, 2)
#   assert_equal(set(2).rgt, 3)
#   assert_equal(set(1).rgt, 4)
#   
#   # Check children cound
#   assert_equal(set(1).all_children_count, 1)
#   
#   set(3).move_to_child_of set(1)
#   
#   #check boundries
#   assert_equal(set(1).lineage, 1)
#   assert_equal(set(2).lineage, 2)
#   assert_equal(set(2).rgt, 3)
#   assert_equal(set(3).lineage, 4)
#   assert_equal(set(3).rgt, 5)
#   assert_equal(set(1).rgt, 6)
#   
#   # How is the count looking?
#   assert_equal(set(1).all_children_count, 2)
#
#   set(4).move_to_child_of set(2)
#
#   # boundries
#   assert_equal(set(1).lineage, 1)
#   assert_equal(set(2).lineage, 2)
#   assert_equal(set(4).lineage, 3)
#   assert_equal(set(4).rgt, 4)
#   assert_equal(set(2).rgt, 5)
#   assert_equal(set(3).lineage, 6)
#   assert_equal(set(3).rgt, 7)
#   assert_equal(set(1).rgt, 8)
#   
#   # Children count
#   assert_equal(set(1).all_children_count, 3)
#   assert_equal(set(2).all_children_count, 1)
#   assert_equal(set(3).all_children_count, 0)
#   assert_equal(set(4).all_children_count, 0)
#   
#   set(5).move_to_child_of set(2)
#   set(6).move_to_child_of set(4)
#   
#   assert_equal(set(2).all_children_count, 3)
#
#   # Children accessors
#   assert_equal(set(1).full_set.length, 6)
#   assert_equal(set(2).full_set.length, 4)
#   assert_equal(set(4).full_set.length, 2)
#   
#   assert_equal(set(1).all_children.length, 5)
#   assert_equal(set(6).all_children.length, 0)
#   
#   assert_equal(set(1).children.length, 2)
#
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
#
# def test_common_usage
#   mixins(:set_2).move_to_child_of(mixins(:set_1))
#   assert_equal(1, mixins(:set_1).children.length)
#
#   mixins(:set_3).move_to_child_of(mixins(:set_2))                     
#   assert_equal(1, mixins(:set_1).children.length)     
#   
#   # Local cache is now out of date!
#   # Problem: the update_alls update all objects up the tree
#   mixins(:set_1).reload
#   assert_equal(2, mixins(:set_1).all_children.length)              
#   
#   assert_equal(1, mixins(:set_1).lineage)
#   assert_equal(2, mixins(:set_2).lineage)
#   assert_equal(3, mixins(:set_3).lineage)
#   assert_equal(4, mixins(:set_3).rgt)
#   assert_equal(5, mixins(:set_2).rgt)
#   assert_equal(6, mixins(:set_1).rgt)  
#   assert(mixins(:set_1).parent == nil)    
#   
#   assert_equal(2, mixins(:set_1).all_children.length)
#   mixins(:set_4).move_to_child_of mixins(:set_1)
#   assert_equal(3, mixins(:set_1).all_children.length)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_move_to_child_of_1
#   bill = NestedSetWithStringScope.new(:root_id => 101, :pos => 2)
#   assert_raise(ActiveRecord::ActiveRecordError) { bill.move_to_child_of(set2(1)) }    
#   assert_raise(ActiveRecord::ActiveRecordError) { set2(1).move_to_child_of(set2(1)) }    
#   assert_raise(ActiveRecord::ActiveRecordError) { set2(4).move_to_child_of(set2(9)) }    
#   assert bill.save
#   assert_nothing_raised {set2(1).reload.check_subtree}
#   assert bill.move_to_left_of(set2(3))
#   assert_equal set2(1), bill.parent
#   assert_equal 4, bill.lineage
#   assert_equal 5, bill.rgt
#   assert_equal 3, set2(2).reload.rgt
#   assert_equal 6, set2(3).reload.lineage
#   assert_equal 22, set2(1).reload.rgt
#   assert_nothing_raised {set2(1).reload.check_subtree}
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
#   set2(9).move_to_child_of(101) # pass an ID instead
#   assert set2(1).children.include?(set2(9))
#   assert_equal(18, set2(9).lineage) # to the right of existing children?
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_move_to_child_of_2
#   bill = NestedSetWithStringScope.new(:root_id => 101)
#   assert_nothing_raised {set2(1).check_subtree}
#   assert bill.save
#   assert bill.move_to_child_of(set2(10))
#   assert_equal set2(10), bill.parent
#   assert_equal 17, bill.lineage
#   assert_equal 18, bill.rgt
#   assert_equal 16, set2(10).reload.lineage
#   assert_equal 19, set2(10).reload.rgt
#   assert_equal 15, set2(9).reload.lineage
#   assert_equal 20, set2(9).reload.rgt
#   assert_equal 21, set2(4).reload.rgt
#   assert_nothing_raised {set2(9).reload.check_subtree}
#   assert_nothing_raised {set2(4).reload.check_subtree}
#   assert_nothing_raised {set2(1).reload.check_subtree}
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_move_to_child_of_3
#   bill = NestedSetWithStringScope.new(:root_id => 101)
#   assert bill.save
#   assert bill.move_to_child_of(set2(3))
#   assert_equal(11, bill.lineage) # to the right of existing children?
#   assert_nothing_raised {set2(1).reload.check_subtree}
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_move_1
#   set2(4).move_to_child_of(set2(3))
#   assert_equal(set2(3), set2(4).reload.parent)
#   assert_equal(1, set2(1).reload.lineage)
#   assert_equal(20, set2(1).reload.rgt)
#   assert_equal(4, set2(3).reload.lineage)
#   assert_equal(19, set2(3).reload.rgt)
#   assert_nothing_raised {set2(1).reload.check_subtree}
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_move_2
#   initial = set2(1).full_set
#   assert_raise(ActiveRecord::ActiveRecordError) { set2(3).move_to_child_of(set2(6)) } # can't set a current child as the parent-- creates a loop
#   assert_raise(ActiveRecord::ActiveRecordError) { set2(3).move_to_child_of(set2(3)) }
#   set2(2).move_to_child_of(set2(5))
#   set2(4).move_to_child_of(set2(2))
#   set2(10).move_to_right_of(set2(3))
#   
#   assert_equal 105, set2(2).parent_id
#   assert_equal 102, set2(4).parent_id
#   assert_equal 101, set2(10).parent_id
#   set2(3).reload
#   set2(10).reload
#   assert_equal 19, set2(10).rgt
#   assert_equal 17, set2(3).rgt
#   assert_equal 2, set2(3).lineage
#   set2(1).reload
#   assert_nothing_raised {set2(1).check_subtree}
#   set2(4).move_to_right_of(set2(3))
#   set2(10).move_to_child_of(set2(9))
#   set2(2).move_to_left_of(set2(3))
#   
#   # now everything should be back where it started-- check against initial
#   final = set2(1).reload.full_set
#   assert_equal(initial, final)
#   for i in 0..9
#     assert_equal(initial[i]['parent_id'], final[i]['parent_id'])
#     assert_equal(initial[i]['lineage'], final[i]['lineage'])
#     assert_equal(initial[i]['rgt'], final[i]['rgt'])
#   end
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_scope_enforcement # prevent moves between trees
#   ns = NestedSetWithStringScope.create(:root_id => 214)
#   assert_raise(ActiveRecord::ActiveRecordError) { ns.move_to_child_of(set2(1)) }
# end
# 
# ##########################################
# # ACTS_AS_LIST-LIKE BEHAVIOUR TESTS
# ##########################################  
# 
# def test_swap
#   set2(5).swap(set2(7))
#   assert_equal [107, 106, 105], set2(3).children.map(&:id)   
#   assert_nothing_raised {set2(3).check_full_tree}
#   assert !set2(3).swap(set2(10)) # isn't a sibling...
# end
# 
# def test_move_higher
#   set2(7).move_higher
#   assert_equal [105, 107, 106], set2(3).children.map(&:id)
#   set2(7).move_higher
#   assert_equal [107, 105, 106], set2(3).children.map(&:id)
#   set2(7).move_higher
#   assert_equal [107, 105, 106], set2(3).children.map(&:id)
# end
# 
# def test_move_lower
#   set2(5).move_lower
#   assert_equal [106, 105, 107], set2(3).children.map(&:id)
#   set2(5).move_lower
#   assert_equal [106, 107, 105], set2(3).children.map(&:id)
#   set2(5).move_lower
#   assert_equal [106, 107, 105], set2(3).children.map(&:id)
# end
# 
# def test_move_to_top
#   set2(7).move_to_top
#   assert_equal [107, 105, 106], set2(3).children.map(&:id)
# end
# 
# def test_move_to_bottom
#   set2(5).move_to_bottom
#   assert_equal [106, 107, 105], set2(3).children.map(&:id)
# end
# 
# ##########################################
# # RENUMBERING TESTS
# ##########################################
# # see also class method tests of renumber_all
# def test_renumber_full_tree_1
#   NestedSetWithStringScope.update_all("lineage = NULL, rgt = NULL", "root_id = 101")
#   assert_raise(ActiveRecord::ActiveRecordError) {set2(1).check_full_tree}
#   set2(1).renumber_full_tree
#   set2(1).reload
#   assert_equal 1, set2(1).lineage
#   assert_equal 20, set2(1).rgt
#   assert_equal 4, set2(3).lineage
#   assert_equal 11, set2(3).rgt
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_renumber_full_tree_2
#   NestedSetWithStringScope.update_all("lineage = lineage + 1, rgt = rgt + 1", "root_id = 101")
#   assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
#   set2(1).renumber_full_tree
#   assert_nothing_raised(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
#   NestedSetWithStringScope.update_all("rgt = 12", "id = 108")
#   assert_raise(ActiveRecord::ActiveRecordError) {set2(8).check_subtree}
#   set2(8).renumber_full_tree
#   assert_nothing_raised(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
# end
# 
# 
# ##########################################
# # CONCURRENCY TESTS
# ##########################################
# # what happens when multiple objects are being manipulated at the same time?
# def test_concurrent_save
#   c1, c2, c3 = Category.create, Category.create, Category.create
#   c1.move_to_right_of(c3)
#   c2.save
#   assert_nothing_raised {Category.check_all}
#   
#   ns1 = set2(3)
#   ns2 = set2(4)
#   ns2.move_to_left_of(102) # ns1 is now out-of-date
#   ns1.save
#   assert_nothing_raised {set2(1).check_subtree}
# end
# 
# def test_concurrent_add_add
#   c1 = Category.new
#   c2 = Category.new
#   c1.save
#   c2.save
#   c3 = Category.new
#   c4 = Category.new
#   c4.save # now in the opposite order
#   c3.save
#   assert_nothing_raised {Category.check_all}
# end
# 
# def test_concurrent_add_delete
#   ns = set2(3)
#   new_ns = NestedSetWithStringScope.create(:root_id => 101)
#   ns.destroy
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_concurrent_add_move
#   ns = set2(3)
#   new_ns = NestedSetWithStringScope.create(:root_id => 101)
#   ns.move_to_left_of(102)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_concurrent_delete_add
#   ns = set2(3)
#   new_ns = NestedSetWithStringScope.new(:root_id => 101)
#   ns.destroy
#   new_ns.save
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_concurrent_delete_delete
#   ns1 = set2(3)
#   ns2 = set2(4)
#   ns1.destroy
#   ns2.destroy
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_concurrent_delete_move
#   ns1 = set2(3)
#   ns2 = set2(4)
#   ns1.destroy
#   ns2.move_to_left_of(102)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_concurrent_move_add
#   ns = set2(3)
#   new_ns = NestedSetWithStringScope.new(:root_id => 101)
#   ns.move_to_left_of(102)
#   new_ns.save
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_concurrent_move_delete
#   ns1 = set2(3)
#   ns2 = set2(4)
#   ns2.move_to_left_of(102)
#   ns1.destroy
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_concurrent_move_move
#   ns1 = set2(3)
#   ns2 = set2(4)
#   ns1.move_to_left_of(102)
#   ns2.move_to_child_of(102)
#   assert_nothing_raised {NestedSetWithStringScope.check_all}    
# end
# 
# ##########################################
# # CALLBACK TESTS
# ##########################################
# # Because the nested set code relies heavily on callbacks, we
# # want to ensure that we aren't causing problems for user-defined callbacks
# def test_callbacks    
#   # 1) Do all user-defined callbacks work?
#   $callbacks = []
#   ns = NS2.new(:root_id => 101) # NS2 adds symbols to $callbacks when the callbacks fire
#   assert_equal([], $callbacks)
#   ns.save!
#   assert_equal([:before_save, :before_create, :after_create, :after_save], $callbacks)
#   $callbacks = []
#   ns.pos = 2
#   ns.save!
#   assert_equal([:before_save, :before_update, :after_update, :after_save], $callbacks)
#   $callbacks = []
#   ns.destroy
#   assert_equal([:before_destroy, :after_destroy], $callbacks)
# end
# 
# def test_callbacks2
#   # 2) Do our callbacks still work, even when a programmer defines 
#   # their own callbacks in the overwriteable style?
#   # (the NS2 model defines callbacks in the overwritable style)
#   ns = NS2.create(:root_id => 101)
#   assert ns.lineage != nil && ns.rgt != nil
#   child_ns = ns.children.create(:root_id => 101)
#   id = child_ns.id
#   ns.destroy
#   assert_equal(nil, NS2.find(:first, :conditions => "id = #{id}"))
#   # lots of implicit testing occurs in other test methods
# end
#
# ##########################################
# # BUG-SPECIFIC TESTS
# ##########################################
# def test_ticket_17
#   main = Category.new
#   main.save
#   sub = Category.new
#   sub.save
#   sub.move_to_child_of main
#   sub.save
#   main.save
#   
#   assert_equal(1, main.all_children_count)
#   assert_equal([main, sub], main.full_set)
#   assert_equal([sub], main.all_children)
#   
#   assert_equal(1, main.lineage)
#   assert_equal(2, sub.lineage)
#   assert_equal(3, sub.rgt)
#   assert_equal(4, main.rgt)
# end
# 
# def test_ticket_19    
#   # this test currently relies on the fact that objects are reloaded at the beginning of the move_to methods
#   root = Category.create
#   first = Category.create
#   second = Category.create
#   first.move_to_child_of(root)
#   second.move_to_child_of(root)    
#   
#   # now we should have the situation described in the ticket
#   assert_nothing_raised {first.move_to_child_of(second)}    
#   assert_raise(ActiveRecord::ActiveRecordError) {second.move_to_child_of(first)} # try illegal move
#   first.move_to_child_of(root) # move it back
#   assert_nothing_raised {first.move_to_child_of(second)} # try it the other way-- first is now on the other side of second
#   assert_nothing_raised {Category.check_all}
# end
# 
# # Note that single-table inheritance recieves extensive implicit testing,
# # because one of the fixture trees contains a hodge-podge of classes.
# def test_ticket_10
#   assert_equal(9, set2(1).all_children.size)
#   NS2.find(103).move_to_right_of(104)
#   assert_equal(4, set2(4).lineage)
#   assert_equal(10, set2(9).rgt)
#   NS2.find(103).destroy
#   assert_equal(12, set2(1).rgt)
#   assert_equal(6, NestedSetWithStringScope.count(:conditions => "root_id = 101"))
#   assert_nothing_raised {NestedSetWithStringScope.check_all}
# end
# 
# def test_ticket_18
#   root = set2(1)
#   assert_nothing_raised {root.full_set(:include => :parent)}
#   assert_nothing_raised {root.full_set(:include => :children)}
#   assert_nothing_raised {root.all_children(:include => :parent)}
#   assert_nothing_raised {root.all_children(:include => :children)}
#   assert_nothing_raised {root.ancestors(:include => :parent)}
#   assert_nothing_raised {root.ancestors(:include => :children)}
# end
# 
end



###################################################################
## Tests that don't pass yet or haven't been finished

## remove argument from assert_nothing_raised

## make #destroy set left & rgt to nil? 

#def test_find_insertion_point
#  bill = NestedSetWithStringScope.create(:pos => 2, :root_id => 101)
#  assert_equal 3, bill.find_insertion_point(set2(1))
#  assert_equal 4, bill.find_insertion_point(set2(3))
#  aalfred = NestedSetWithStringScope.create(:pos => 0, :root_id => 101)
#  assert_equal 1, aalfred.find_insertion_point(set2(1))
#  assert_equal 2, aalfred.find_insertion_point(set2(2))
#  assert_equal 12, aalfred.find_insertion_point(set2(4))
#  zed = NestedSetWithStringScope.create(:pos => 99, :root_id => 101)
#  assert_equal 19, zed.find_insertion_point(set2(1))
#  assert_equal 17, zed.find_insertion_point(set2(9))
#  assert_equal 16, zed.find_insertion_point(set2(10))
#  assert_equal 10, set2(4).find_insertion_point(set2(3))
#end
#
