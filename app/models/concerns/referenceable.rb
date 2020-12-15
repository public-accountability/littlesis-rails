# frozen_string_literal: true

module Referenceable
  extend ActiveSupport::Concern
  include Pagination

  included do
    has_many :references, as: :referenceable, dependent: :destroy
    has_many :documents, through: :references

    validate :valid_new_reference?
  end

  # validate_reference will invalidate the instance. Many edit actions on LittleSis
  # require a valid source url, and this hacks into ActiveModel validation so that
  # entity.validate_reference(url: 'foobar').valid? returns false even though url
  # is not an attribute of Entity and no field on Entity was changed.
  # Hash -> self
  def validate_reference(attrs)
    document_attributes = Document::DocumentAttributes.new(attrs)

    if document_attributes.valid?
      define_singleton_method(:valid_new_reference?) { nil }
    else
      define_singleton_method(:valid_new_reference?) do
        errors.add :base, document_attributes.error_message
      end
    end

    self
  end

  def add_reference(attrs)
    raise ActiveRecord::RecordNotSaved, "#{self} is not saved" unless persisted?

    dattrs = Document::DocumentAttributes.new(attrs)
    dattrs.validate!
    @_last_reference = ApplicationRecord.transaction do
      references.find_or_create_by!(document: dattrs.find_or_create_document)
    end

    after_add_reference if respond_to?(:after_add_reference)

    self
  end

  def last_reference
    return @_last_reference if @_last_reference

    references.last
  end

  def documents_count
    documents.count
  end

  def all_documents(page, per_page = 20)
    documents.page(page).per(per_page)
  end

  protected

  # Required by `validate :valid_new_reference? `
  def valid_new_reference?; end
end
