class Person < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :person
end