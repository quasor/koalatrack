# == Schema Information
#
# Table name: playlist_test_cases
#
#  id                         :integer(4)      not null, primary key
#  playlist_id                :integer(4)
#  test_case_id               :integer(4)
#  test_case_version          :integer(4)
#  user_id                    :integer(4)
#  created_at                 :datetime
#  updated_at                 :datetime
#  test_case_executions_count :integer(4)      default(0)
#  last_result                :integer(4)      default(0)
#  position                   :integer(4)
#

class PlaylistTestCase < ActiveRecord::Base
#  acts_as_solr :fields => [:title, :bug, :assignedto, :body, :priority, :category, :playlistid, :result]
  belongs_to :playlist
  acts_as_list :scope => :playlist

  belongs_to :user
  belongs_to :test_case, :class_name => "KoalaTestCase"
  has_many :test_case_executions

	define_index do
		indexes test_case.title, :as => :title
		indexes user.login, :as => :assignedto		
		indexes test_case.body, :as => :body
		indexes test_case.category.name, :as => :category
		indexes test_case.priority_in_feature, :as => :priority
		has playlist_id, user_id, test_case_executions_count
	end


  #Solr helpers:
  def title
    test_case.title
  end
  def result
    last_result
  end

  def playlistid
    playlist.id.to_i
  end
  
  def bug
    test_case_executions.collect(&:bug_id).uniq.reject { |r| r.blank? }.join ','
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
    @version = test_case.version
    @tce = TestCaseExecution.create( :playlist_test_case_id => id, 
      :test_case_id => test_case_id, :user_id => user_id, 
      :test_case_version => @version,:result => 1)                                
  end
  def freeze_version!
    self.test_case_version = self.test_case.version 
    self.save!
    self.test_case_version
  end
end
