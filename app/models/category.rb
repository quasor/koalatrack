# == Schema Information
# Schema version: 13
#
# Table name: categories
#
#  id         :integer(11)   not null, primary key
#  name       :string(255)   
#  parent_id  :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Category < ActiveRecord::Base
  has_many :test_cases
  
  validates_presence_of :name
end
