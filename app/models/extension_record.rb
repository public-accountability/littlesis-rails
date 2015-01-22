class ExtensionRecord < ActiveRecord::Base
  include SingularTable
  
  belongs_to :entity, inverse_of: :extension_records
  belongs_to :extension_definition, foreign_key: "definition_id", inverse_of: :extension_records  
end