class ExternalKey < ApplicationRecord
  include SingularTable

  belongs_to :entity, inverse_of: :external_keys
  belongs_to :domain, inverse_of: :external_keys
end