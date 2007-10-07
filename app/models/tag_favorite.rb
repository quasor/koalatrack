class TagFavorite < ActiveRecord::Base
  belongs_to :tag
  validates_uniqueness_of :tag_id
  validates_presence_of :tag_id
end
