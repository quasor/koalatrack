# == Schema Information
# Schema version: 38
#
# Table name: groups
#
#  id          :integer(11)   not null, primary key
#  name        :string(255)   
#  description :text          
#  created_at  :datetime      
#  updated_at  :datetime      
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
end
