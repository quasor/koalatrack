# == Schema Information
# Schema version: 36
#
# Table name: tag_favorites
#
#  id         :integer(11)   not null, primary key
#  tag_id     :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#  group_id   :integer(11)   
#

class TagFavorite < ActiveRecord::Base
  belongs_to :tag
  belongs_to :group
  validates_uniqueness_of :tag_id
  validates_presence_of :tag_id
end
