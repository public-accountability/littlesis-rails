class Family < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :family
end