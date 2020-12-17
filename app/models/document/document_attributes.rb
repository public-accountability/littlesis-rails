# frozen_string_literal: true

class Document
  class DocumentAttributes
    attr_reader :attributes
    extend Forwardable

    def_delegators :@attributes, :to_h, :[], :fetch

    def initialize(attrs)
      @attributes = attrs.to_h.with_indifferent_access

      if @attributes[:name].blank? && !primary_source?
        @attributes[:name] = @attributes[:url]&.slice(0, 255)
      end

      freeze
    end

    def find_or_create_document
      if primary_source?
        Document.create!(ref_type: 'primary_source',
                         primary_source_document: primary_source_document,
                         name: name)
      else
        Document.find_or_create!(@attributes)
      end
    end

    def url
      @attributes[:url]
    end

    def name
      @attributes[:name]
    end

    def primary_source_document
      @attributes[:primary_source_document]
    end

    def valid?
      return false if name && name.length >= 255

      primary_source? || (url.present? && Document.valid_url?(url))
    end

    def validate!
      raise InvalidDocumentError, error_message unless valid?
    end

    def error_message
      if url.blank?
        'A source URL is required'
      elsif !Document.valid_url?(url)
        "\"#{url}\" is not a valid url"
      elsif name.length >= 255
        'Name is too long (maximum is 255 characters)'
      end
    end

    class InvalidDocumentError < Exceptions::LittleSisError; end

    private

    def primary_source?
      primary_source_document.is_a?(IO) || primary_source_document.is_a?(ActionDispatch::Http::UploadedFile)
    end
  end
end
