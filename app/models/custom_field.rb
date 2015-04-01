class CustomField < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :custom_fields
end