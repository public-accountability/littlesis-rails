class RelationshipCategory < ActiveRecord::Base
  include SingularTable

  has_many :relationships, inverse_of: :category
end