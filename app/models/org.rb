class Org < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :org
end