class Donation < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :donation
end