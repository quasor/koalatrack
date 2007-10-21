# == Schema Information
# Schema version: 36
#
# Table name: file_attachments
#
#  id           :integer(11)   not null, primary key
#  parent_id    :integer(11)   
#  test_case_id :integer(11)   
#  content_type :string(255)   
#  filename     :string(255)   
#  thumbnail    :string(255)   
#  size         :integer(11)   
#  width        :integer(11)   
#  height       :integer(11)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

class FileAttachment < ActiveRecord::Base
  has_attachment :storage => :file_system
  belongs_to :test_case
end
