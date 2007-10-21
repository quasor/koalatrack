# == Schema Information
# Schema version: 36
#
# Table name: roles
#
#  id         :integer(11)   not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Role < ActiveRecord::Base
end
