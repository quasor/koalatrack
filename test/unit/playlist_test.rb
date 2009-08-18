# == Schema Information
#
# Table name: playlists
#
#  id           :integer(4)      not null, primary key
#  title        :string(255)
#  description  :text
#  user_id      :integer(4)
#  milestone_id :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  dead         :boolean(1)
#

require File.dirname(__FILE__) + '/../test_helper'

class PlaylistTest < Test::Unit::TestCase
  fixtures :playlists

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
