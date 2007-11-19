# == Schema Information
# Schema version: 38
#
# Table name: playlist_test_cases
#
#  id                         :integer(11)   not null, primary key
#  playlist_id                :integer(11)   
#  test_case_id               :integer(11)   
#  test_case_version          :integer(11)   
#  user_id                    :integer(11)   
#  created_at                 :datetime      
#  updated_at                 :datetime      
#  test_case_executions_count :integer(11)   default(0)
#  last_result                :integer(11)   default(0)
#  position                   :integer(11)   
#

class PlaylistTestCase < ActiveRecord::Base
  acts_as_solr :fields => [:title, :bug_id, :assignedto, :body, :priority, :category, :playlistid]
  belongs_to :playlist
  acts_as_list :scope => :playlist

  belongs_to :user
  belongs_to :test_case
  has_many :test_case_executions

  #Solr helpers:
  def title
    test_case.title
  end

  def playlistid
    playlist.id.to_i
  end
  
  def bug_id
    test_case_executions.bug_id
  end
  
  def assignedto
    user.login
  end
  
  def body
    test_case.body
  end
  
  def priority
    test_case.priority_in_feature.to_i
  end
  
  def category
    test_case.category.name
  end
    
  after_create { |r| r.insert_at unless r.in_list? }
      
  validates_uniqueness_of :test_case_id, :scope => :playlist_id
  validates_presence_of :playlist_id, :test_case_id, :user_id
  
  def pass_by!(user_id)
    @version = test_case_version || test_case.version
    @tce = TestCaseExecution.create( :playlist_test_case_id => id, 
      :test_case_id => test_case_id, :user_id => user_id, 
      :test_case_version => @version,:result => 1)                                
  end
end
