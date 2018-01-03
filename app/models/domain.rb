class Domain < ApplicationRecord
  include SingularTable

  TWITTER_ID = 1

  has_many :external_keys, inverse_of: :domain
end