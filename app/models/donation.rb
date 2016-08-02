class Donation < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :donation
  has_many :os_matches, inverse_of: :donation
end
