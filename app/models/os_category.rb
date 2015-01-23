class OsCategory < ActiveRecord::Base
  include SingularTable

  has_many :os_entity_categories, primary_key: "category_id", inverse_of: :os_category
  has_many :entities, through: :os_entity_categories, inverse_of: :os_categories
end