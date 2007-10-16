# == Schema Information
# Schema version: 29
#
# Table name: categories
#
#  id             :integer(11)   not null, primary key
#  name           :string(255)   
#  parent_id      :integer(11)   
#  created_at     :datetime      
#  updated_at     :datetime      
#  children_count :integer(11)   default(0)
#

class Category < ActiveRecord::Base
  acts_as_tree :counter_cache => :children_count
  has_many :test_cases
  
  validates_presence_of :name
end
