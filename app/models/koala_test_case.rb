# == Schema Information
#
# Table name: koala_test_cases
#
#  id                    :integer(4)      not null, primary key
#  title                 :string(255)
#  body                  :text
#  user_id               :integer(4)
#  priority_in_feature   :integer(4)
#  priority_in_product   :integer(4)
#  estimate_in_hours     :float
#  automated             :boolean(1)
#  created_at            :datetime
#  updated_at            :datetime
#  updated_by            :integer(4)
#  category_id           :integer(4)
#  tag                   :string(255)
#  qatraq_id             :integer(4)
#  version               :integer(4)
#  project_id            :string(255)
#  active                :boolean(1)      default(TRUE)
#  automation_class_path :string(255)
#

class KoalaTestCase < ActiveRecord::Base
  acts_as_taggable_on :tags
  
  #set_cached_tag_list_column_name "tag"
  
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
  has_many :playlist_test_cases, :foreign_key => :test_case_id
  has_many :test_case_executions, :foreign_key => :test_case_id
  has_many :file_attachments, :foreign_key => :test_case_id
  
#  acts_as_solr :fields => [:title, :body, :tag, :owner, :project_id, :ancestor_ids]

	define_index do
		indexes :title
		indexes :body
		has category_id, user_id, active
	end
	

  validates_presence_of     :title#, :body
#  validates_uniqueness_of    :title, :scope => :category_id, :message => "of this test case has already been used in this sub-category"

  def body
    s = super
    unless s.nil?
      s = s.gsub(/&ldquo;|&rdquo;/,'&quot;')
      s = s.gsub(/Wingdings/,'Arial')
      s = s.gsub(/<!--.*?-->/,'')
    end
    s
  end

  def logical_delete
    self.active = false
    save
  end
end
