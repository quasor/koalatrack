# == Schema Information
#
# Table name: file_attachments
#
#  id           :integer(4)      not null, primary key
#  parent_id    :integer(4)
#  test_case_id :integer(4)
#  content_type :string(255)
#  filename     :string(255)
#  thumbnail    :string(255)
#  size         :integer(4)
#  width        :integer(4)
#  height       :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class FileAttachmentTest < Test::Unit::TestCase
  fixtures :file_attachments

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
