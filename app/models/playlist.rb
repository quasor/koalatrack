# == Schema Information
# Schema version: 38
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
  acts_as_ferret :fields => [:title, :milestone_name, :user], :remote => true
  belongs_to :milestone
  has_many :playlist_test_cases, :order => :position
  has_many :test_cases, :through => :playlist_test_cases, :source => :test_case
  belongs_to :user
  #add_index :fields => ['title', 'milestone.name AS milestone', 'user.login AS user'] 
  
  def milestone_name
    self.milestone.name
  end
  validates_presence_of :title
  
  
end
