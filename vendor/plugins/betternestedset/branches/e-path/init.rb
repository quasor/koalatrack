# better_nested_set
# (c) 2005 Jean-Christophe Michel 
# MIT licence
#
require 'better_nested_set'

ActiveRecord::Base.class_eval do
  include FooCom::Acts::EnumeratedPath
end
