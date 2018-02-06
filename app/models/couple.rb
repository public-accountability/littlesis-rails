class Couple < ApplicationRecord
  include SingularTable

  has_paper_trail :on => [:update]

  belongs_to :entity, inverse_of: :couple
  belongs_to :partner1, class_name: "Entity"
  belongs_to :partner2, class_name: "Entity"
end
