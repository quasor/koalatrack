# == Schema Information
# Schema version: 38
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
  def ancestor_ids
    self.category.self_and_ancestors.collect(&:id).join(',')
  end
  belongs_to :user
  belongs_to :category
  belongs_to :updater,  :class_name => 'User', :foreign_key => "updated_by"  
  has_many :playlist_test_cases
  has_many :test_case_executions
  has_many :file_attachments
  
  acts_as_solr :fields => [:title, :body, :tag, :owner, :project_id, :ancestor_ids]
  validates_presence_of     :title#, :body
#  validates_uniqueness_of    :title, :scope => :category_id, :message => "of this test case has already been used in this sub-category"

  def stripped_body
    body.gsub(/&ldquo;|&rdquo;/,'&quot;')
  end

  def logical_delete
    self.active = false
    save
  end
end
