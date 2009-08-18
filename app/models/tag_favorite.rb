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

class TagFavorite < ActiveRecord::Base
  belongs_to :tag
  belongs_to :group
  validates_uniqueness_of :tag_id
  validates_presence_of :tag_id
  def global?
    group_id == nil
  end
  
  def self.global_tags
    find_all_by_group_id(nil)
  end
end
