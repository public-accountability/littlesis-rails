class Transaction < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :trans
end