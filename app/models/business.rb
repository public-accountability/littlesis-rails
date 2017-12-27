class Business < ApplicationRecord
  include SingularTable

  belongs_to :entity, inverse_of: :business
end