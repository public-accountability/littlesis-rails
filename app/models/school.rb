class School < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :school
end