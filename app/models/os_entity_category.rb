# frozen_string_literal: true

class OsEntityCategory < ApplicationRecord
  belongs_to :os_category, foreign_key: "category_id", primary_key: "category_id", inverse_of: :os_entity_categories, optional: true
  belongs_to :entity, inverse_of: :os_entity_categories
end
