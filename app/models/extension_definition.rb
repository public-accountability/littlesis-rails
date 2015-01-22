class ExtensionDefinition < ActiveRecord::Base
  include SingularTable

  has_many :extension_records, inverse_of: :extension_definition
  has_many :entities, through: :extension_records, inverse_of: :extension_definitions  
end