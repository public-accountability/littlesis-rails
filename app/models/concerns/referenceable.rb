# frozen_string_literal: true

module Referenceable
  extend ActiveSupport::Concern
  include Pagination

  included do
    has_many :references, as: :referenceable, dependent: :destroy
    has_many :documents, through: :references

    validate :valid_new_reference?
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # invalides the model if the reference url or name is invalid
  def validate_reference(attrs)
    self.document_attributes = attrs

    return if document_url.blank? && reference_optional?

    if document_url.blank?
      reference_error 'A source URL is required'
    elsif !Document.valid_url?(document_url)
      reference_error "\"#{document_url}\" is not a valid url"
    elsif name_too_long?
      reference_error 'name is too long (maximum is 255 characters)'
    else
      define_singleton_method(:valid_new_reference?) { nil }
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # Hash -> self
  def add_reference(document_attributes)
    unless persisted?
      raise ActiveRecord::RecordNotSaved, "Can't create a reference for an unpersisted record"
    end

    validate_reference(document_attributes)

    if valid?
      return if document_url.blank? && reference_optional?

      create_document_reference
    end

    self
  end

  def add_reference_by_document_id(document_id)
    if Document.find_by(id: document_id).blank?
      raise ArgumentError, "No document found with id: #{document_id}"
    end

    references.create(document_id: document_id) unless references.exists?(document_id: document_id)
  end

  def documents_count
    if is_a?(Entity)
      Document.documents_count_for_entity(self)
    else
      documents.count
    end
  end

  # For an entity `all_documents` includes the documents
  # for it's relationships as well (via Document.documents_for_entity)
  # If called on another type of references, it simply paginates documents
  # Int | Int -> KimainariArray
  def all_documents(page, per_page = 20)
    if is_a?(Entity)
      paginate(
        page,
        per_page,
        Document.documents_for_entity(entity: self, page: page, per_page: per_page),
        Document.documents_count_for_entity(self)
      )
    else
      documents.page(page).per(per_page)
    end
  end

  # Hash -> ?Reference
  def save_with_reference(reference_attrs)
    # TODO: @aepyornis would like to think about
    #   if we want to yield to a block here for entities
    #   b/c of need to update their extension records
    validate_reference(reference_attrs)
    if valid?
      save!
      add_reference(reference_attrs)
      return find_reference_by_url(reference_attrs[:url])
    end
    return nil
  end

  def find_reference_by_url(document_url)
    # find references associating *this* particular referenceable with a document with a given url
    # (this method is not a class method on `Reference` because we don't want all references)
    references.find_by(document_id: Document.find_by(url: document_url).id)
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

  def reference_optional?
    self.class.respond_to?(:reference_optional?) && self.class.reference_optional?
  end

  def document_attributes=(attrs)
    @document_attributes = attrs
  end

  def document_name
    @document_attributes[:name] || @document_attributes['name']
  end

  def document_url
    @document_attributes[:url] || @document_attributes['url']
  end

  def find_or_create_document
    Document.find_by(url: document_url) || Document.create!(@document_attributes)
  end

  def name_too_long?
    document_name.present? && document_name.length > 255
  end

  def create_document_reference
    document = find_or_create_document
    return if references.exists?(document_id: document.id)

    references.create(document_id: document.id)
  end
end
