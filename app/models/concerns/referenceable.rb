module Referenceable
  extend ActiveSupport::Concern

  included do
    has_many :references, as: :referenceable
    has_many :documents, through: :references

    validate :valid_new_reference?
  end

  # def references(options = {})
  #   refs = Reference.where(object_model: self.class.table_name.classify, object_id: id)
  #   refs = refs.order('updated_at DESC') if options[:order]
  #   refs = refs.limit(options[:limit]) if options[:limit]
  #   refs
  # end

  # Hash -> self
  def add_reference(document_attributes)
    raise ActiveRecord::RecordNotSaved, "Can't create a reference for an unpersisted record" unless persisted?

    url = document_attributes[:url] || document_attributes['url']
    raise ArgumentError, "Missing required attribute: Url" if url.blank?

    begin
      doc = Document.find_by_url(url) || Document.create(document_attributes)
      references.create(document_id: doc.id) unless references.exists?(document_id: doc.id)
    rescue Exceptions::InvalidUrlError
      # The modules adds a validation check that executes the method `valid_new_reference?`
      # By default the method is empty, but if the URL is invalid
      # this will change the method's definition to append an error on the referenceable.
      define_singleton_method(:valid_new_reference?) do
        errors.add :base, "#{url} is not a valid url"
      end
    end

    self
  end

  private

  
  # Required by ` validate :valid_new_reference? `
  def valid_new_reference?; end
  
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
