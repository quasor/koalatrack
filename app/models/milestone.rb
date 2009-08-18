# == Schema Information
#
# Table name: milestones
#
#  id         :integer(4)      not null, primary key
#  name       :text
#  due_on     :date
#  created_at :datetime
#  updated_at :datetime
#  group_id   :integer(4)
#

class Milestone < ActiveRecord::Base
  has_many :playlist_test_cases
  belongs_to :group
  validates_presence_of :name
end
