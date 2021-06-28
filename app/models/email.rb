class Email < ApplicationRecord
  belongs_to :entity, inverse_of: :emails
end
