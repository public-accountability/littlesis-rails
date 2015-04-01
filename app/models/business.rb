class Business < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :business
end