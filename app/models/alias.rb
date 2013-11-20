class Alias < ActiveRecord::Base
	include SingularTable
	
	belongs_to :entity, inverse_of: :aliases
end