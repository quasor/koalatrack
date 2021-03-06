# == Schema Information
#
# Table name: groups
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  bug_url     :string(255)
#

class Group < ActiveRecord::Base
  has_many :users
  has_many :test_cases, :through => :users
  has_many :milestones
  has_many :groups
  has_many :categories
  has_many :playlists, :through => :users
  has_many :tag_favorites
  validates_uniqueness_of :name
  def after_create
    self.categories.find_or_create_by_name(:name => self.name)
  end
  
  #http://expediaweb/test/bugs/bug.asp?BugID=
  def bugurl
    bug_url || "http://expediaweb/test/bugs/bug.asp?BugID="
  end
  
end
