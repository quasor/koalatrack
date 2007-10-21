# == Schema Information
# Schema version: 36
#
# Table name: milestones
#
#  id         :integer(11)   not null, primary key
#  name       :text          
#  due_on     :date          
#  created_at :datetime      
#  updated_at :datetime      
#  group_id   :integer(11)   
#

class Milestone < ActiveRecord::Base
  has_many :playlist_test_cases
  belongs_to :group
  validates_presence_of :name
end
