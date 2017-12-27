class Field < ApplicationRecord
  self.inheritance_column = "_type"

  has_many :entity_fields, inverse_of: :field, dependent: :destroy
  has_many :entities, through: :entity_fields, inverse_of: :fields

  validates_inclusion_of :type, in: %w(text number boolean)

  def self.unused
    joins("LEFT JOIN entity_fields ON (entity_fields.field_id = fields.id)").where(entity_fields: { entity_id: nil })
  end

  def self.delete_unused
    unused.delete_all
  end
end