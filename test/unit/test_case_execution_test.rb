# == Schema Information
#
# Table name: test_case_executions
#
#  id                    :integer(4)      not null, primary key
#  playlist_test_case_id :integer(4)
#  test_case_id          :integer(4)
#  test_case_version     :integer(4)
#  user_id               :integer(4)
#  result                :integer(4)
#  bug_id                :string(255)
#  comment               :text
#  created_at            :datetime
#  updated_at            :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class TestCaseExecutionTest < Test::Unit::TestCase
  fixtures :test_case_executions

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
