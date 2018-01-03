class OsEntityPreprocess < ApplicationRecord
  include SingularTable

  belongs_to :entity, inverse_of: :os_entity_preprocesses
end