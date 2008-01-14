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
  acts_as_solr :fields => [:title, :milestone_name, :user]
  belongs_to :milestone
  has_many :playlist_test_cases, :order => :position, :dependent => :destroy
  has_many :test_cases, :through => :playlist_test_cases, :source => :test_case
  has_many :test_case_executions, :through => :playlist_test_cases, :dependent => :destroy
  belongs_to :user
  def milestone_name
    self.milestone.name
  end
  validates_presence_of :title  
  
end

