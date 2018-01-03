class Email < ApplicationRecord
  include SingularTable

  belongs_to :entity, inverse_of: :emails
end