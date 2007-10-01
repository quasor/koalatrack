# == Schema Information
# Schema version: 13
#
# Table name: test_cases
#
#  id                  :integer(11)   not null, primary key
#  title               :string(255)   
#  body                :text          
#  user_id             :integer(11)   
#  priority_in_feature :integer(11)   
#  prioirty_in_product :integer(11)   
#  estimate_in_hours   :float         
#  automated           :boolean(1)    
#  created_at          :datetime      
#  updated_at          :datetime      
#  version             :integer(11)   
#  updated_by          :integer(11)   
#  category_id         :integer(11)   
#

class TestCase < ActiveRecord::Base
  acts_as_taggable
  acts_as_versioned
  acts_as_ferret :fields => [:title, :body, :tags_list_string]
  
  belongs_to :user
  belongs_to :category
  belongs_to :updater,  :class_name => 'User', :foreign_key => "updated_by"  
  has_many :playlist_test_cases
  has_many :test_case_executions
  validates_presence_of     :title, :body
end
