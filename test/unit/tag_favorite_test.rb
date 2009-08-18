# == Schema Information
#
# Table name: tag_favorites
#
#  id         :integer(4)      not null, primary key
#  tag_id     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  group_id   :integer(4)
#

require File.dirname(__FILE__) + '/../test_helper'

class TagFavoriteTest < Test::Unit::TestCase
  fixtures :tag_favorites

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
