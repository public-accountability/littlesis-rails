class Couple < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :couple
  belongs_to :partner1, class_name: "Entity", inverse_of: :couple1
  belongs_to :partner2, class_name: "Entity", inverse_of: :couple2
end