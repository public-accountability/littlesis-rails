class Email < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :emails
end