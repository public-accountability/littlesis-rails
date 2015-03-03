require 'active_support/concern'

module Referenceable
  extend ActiveSupport::Concern

  included do
    default_scope -> { where(is_deleted: false) }
    scope :active, -> { where(is_deleted: false) }
    scope :deleted, -> { where(is_deleted: true) }
  end
  
  def references
    Reference.where(object_model: self.class.name, object_id: id)
  end

  def add_reference(source, name = nil)
    raise "can't create reference for unpersisted record" unless persisted?
    name = source unless name.present?
    Reference.create(
      source: source,
      name: name,
      object_model: self.class.name,
      object_id: id
    )
  end
end