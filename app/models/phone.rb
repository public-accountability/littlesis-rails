class Phone < ApplicationRecord
  include SingularTable

  # necessary for model to work with "type" field
  self.inheritance_column = '_type'

  belongs_to :entity, inverse_of: :phones
end