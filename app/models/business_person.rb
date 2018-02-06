class BusinessPerson < ApplicationRecord
  include SingularTable
  has_paper_trail :on => [:update]
  belongs_to :entity, inverse_of: :business_person
end
