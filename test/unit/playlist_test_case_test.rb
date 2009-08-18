# == Schema Information
#
# Table name: playlist_test_cases
#
#  id                         :integer(4)      not null, primary key
#  playlist_id                :integer(4)
#  test_case_id               :integer(4)
#  test_case_version          :integer(4)
#  user_id                    :integer(4)
#  created_at                 :datetime
#  updated_at                 :datetime
#  test_case_executions_count :integer(4)      default(0)
#  last_result                :integer(4)      default(0)
#  position                   :integer(4)
#

require File.dirname(__FILE__) + '/../test_helper'

class PlaylistTestCaseTest < Test::Unit::TestCase
  fixtures :playlist_test_cases

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
