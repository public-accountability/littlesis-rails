class PublicCompany < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :public_company
end