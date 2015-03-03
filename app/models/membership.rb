class Membership < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :membership
end