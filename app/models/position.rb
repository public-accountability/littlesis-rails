class Position < ActiveRecord::Base
  include SingularTable
  
  belongs_to :relationship, inverse_of: :position
end