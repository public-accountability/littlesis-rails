module Referenceable
  extend ActiveSupport::Concern

  included do
    has_many :references, as: :referenceable
    has_many :documents, through: :references

    validate :valid_new_reference?
  end

  # invalides the model if the reference url or name is invalid
  def validate_reference(document_attributes)
    url = document_attributes[:url] || document_attributes['url']
    name = document_attributes[:name] || document_attributes['name']

    if url.blank?
      reference_error "A source URL is required"
    elsif !Document.valid_url?(url)
      reference_error "\"#{url}\" is not a valid url"
    elsif name.present? && name.length > 255
      reference_error "name is too long (maximum is 255 characters)"
    else
      define_singleton_method(:valid_new_reference?) { nil }
    end
  end

  # Hash -> self
  def add_reference(document_attributes)
    raise ActiveRecord::RecordNotSaved, "Can't create a reference for an unpersisted record" unless persisted?
    validate_reference(document_attributes)

    if self.valid?
      url = document_attributes[:url] || document_attributes['url']
      doc = Document.find_by_url(url) || Document.create(document_attributes)
      references.create(document_id: doc.id) unless references.exists?(document_id: doc.id)
    end

    self
  end

  def documents_count
    if self.is_a?(Entity)
      Document.documents_count_for_entity(self)
    else
      documents.count
    end
  end

  private

  # Required by ` validate :valid_new_reference? `
  def valid_new_reference?; end

  # The modules adds a validation check that executes the method `valid_new_reference?`
  # By default the method is empty, but if the URL is invalid
  # this will change the method's definition to append an error on the referenceable.
  def reference_error(msg)
    define_singleton_method(:valid_new_reference?) do
      errors.add :base, msg
    end
  end
end
