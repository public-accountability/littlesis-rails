class ElectedRepresentative < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :elected_representative
end