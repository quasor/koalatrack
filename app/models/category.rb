class Category < ActiveRecord::Base
  has_many :test_cases
end
