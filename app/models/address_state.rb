class AddressState < ApplicationRecord
  include SingularTable

  has_many :addresses, inverse_of: :state, dependent: :destroy
end