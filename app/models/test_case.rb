# == Schema Information
# Schema version: 36
#
# Table name: test_cases
#
#  id                  :integer(11)   not null, primary key
#  title               :string(255)   
#  body                :text          
#  user_id             :integer(11)   
#  priority_in_feature :integer(11)   
#  priority_in_product :integer(11)   
#  estimate_in_hours   :float         
#  automated           :boolean(1)    
#  created_at          :datetime      
#  updated_at          :datetime      
#  updated_by          :integer(11)   
#  category_id         :integer(11)   
#  tag                 :string(255)   
#  qatraq_id           :integer(11)   
#  version             :integer(11)   
#  project_id          :string(255)   
#

class TestCase < ActiveRecord::Base
  acts_as_taggable
  acts_as_versioned 
  def owner
    user.login
  end
  belongs_to :user
  belongs_to :category
  belongs_to :updater,  :class_name => 'User', :foreign_key => "updated_by"  
  has_many :playlist_test_cases
  has_many :test_case_executions
  has_many :file_attachments
  
  acts_as_ferret :fields => [:title, :body, :tag, :owner, :project_id], :remote => true
  #add_index :fields => %w[title body tag] + ['user.login AS owner'] 
  
  
  validates_presence_of     :title#, :body
end
