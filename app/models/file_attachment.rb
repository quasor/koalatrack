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

class FileAttachment < ActiveRecord::Base
  has_attachment :storage => :file_system
  belongs_to :test_case, :class_name => "KoalaTestCase", :foreign_key => :test_case_id
end
