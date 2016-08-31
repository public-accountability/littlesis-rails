class Education < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :education
  belongs_to :degree
end
