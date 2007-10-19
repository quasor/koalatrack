class Group < ActiveRecord::Base
  has_many :users
  has_many :milestones
  has_many :groups
  has_many :categories
end
