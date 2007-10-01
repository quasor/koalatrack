# == Schema Information
# Schema version: 13
#
# Table name: playlists
#
#  id           :integer(11)   not null, primary key
#  title        :string(255)   
#  description  :text          
#  user_id      :integer(11)   
#  milestone_id :integer(11)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

class Playlist < ActiveRecord::Base
  belongs_to :milestone
  has_many :playlist_test_cases
  has_many :test_cases, :through => :playlist_test_cases, :source => :test_case
  belongs_to :user
  validates_presence_of :title
end
