# == Schema Information
# Schema version: 3
#
# Table name: test_cases
#
#  id                  :integer(11)   not null, primary key
#  title               :string(255)   
#  body                :text          
#  owner_id            :integer(11)   
#  priority_in_feature :integer(11)   
#  prioirty_in_product :integer(11)   
#  estimate_in_hours   :float         
#  automated           :boolean(1)    
#  created_at          :datetime      
#  updated_at          :datetime      
#

class TestCase < ActiveRecord::Base
  acts_as_versioned
  belongs_to :user
  belongs_to :category
  belongs_to :updater,  :class_name => 'User', :foreign_key => "updated_by"  
  validates_presence_of     :title, :body

end
