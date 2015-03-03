class Education < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :education
end