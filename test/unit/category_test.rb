# == Schema Information
#
# Table name: categories
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)
#  parent_id      :integer(4)
#  ancestor_cache :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  children_count :integer(4)      default(0)
#  group_id       :integer(4)
#

require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  fixtures :categories

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
