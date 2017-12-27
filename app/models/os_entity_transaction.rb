class OsEntityTransaction < ApplicationRecord
  include SingularTable

  belongs_to :entity, inverse_of: :os_entity_transactions

  scope :verified, -> { where(is_verified: true) }
end