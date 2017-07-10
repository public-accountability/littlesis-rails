class Position < ActiveRecord::Base
  include SingularTable
  
  has_paper_trail on: [:update, :destroy]
  
  belongs_to :relationship, inverse_of: :position
end
