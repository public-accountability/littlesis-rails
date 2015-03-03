class Ownership < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :ownership
end