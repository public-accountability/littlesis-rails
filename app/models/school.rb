class School < ApplicationRecord
  include SingularTable

  belongs_to :entity, inverse_of: :school
end