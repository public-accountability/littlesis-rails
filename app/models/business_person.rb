class BusinessPerson < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :business_person
end