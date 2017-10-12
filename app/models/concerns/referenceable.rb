module Referenceable
  extend ActiveSupport::Concern

  included do
    has_many :references, as: :referenceable
    has_many :documents, through: :references
  end

  # def references(options = {})
  #   refs = Reference.where(object_model: self.class.table_name.classify, object_id: id)
  #   refs = refs.order('updated_at DESC') if options[:order]
  #   refs = refs.limit(options[:limit]) if options[:limit]
  #   refs
  # end

  # def add_reference(source, name = nil)
  #   raise "can't create reference for unpersisted record" unless persisted?
  #   name = source unless name.present?
  #   Reference.create(
  #     source: source,
  #     name: name,
  #     object_model: self.class.name,
  #     object_id: id
  #   )
  # end
end
