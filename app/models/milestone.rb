# == Schema Information
# Schema version: 29
#
# Table name: milestones
#
#  id         :integer(11)   not null, primary key
#  name       :text          
#  due_on     :date          
#  created_at :datetime      
#  updated_at :datetime      
#

class Milestone < ActiveRecord::Base
  has_many :playlist_test_cases
  validates_presence_of :name
end
