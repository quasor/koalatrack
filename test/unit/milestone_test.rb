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

require File.dirname(__FILE__) + '/../test_helper'

class MilestoneTest < Test::Unit::TestCase
  fixtures :milestones

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
