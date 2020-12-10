# frozen_string_literal: true

class Document
  class DocumentAttributes
    attr_reader :attributes
    extend Forwardable

    def_delegators :@attributes, :to_h, :[], :fetch

    def initialize(attrs)
      @attributes = attrs.to_h.with_indifferent_access

      if @attributes[:name].blank?
        @attributes[:name] = @attributes[:url]&.slice(0, 255)
      end

      freeze
    end

    def find_or_create_document
      Document.find_or_create!(@attributes)
    end

    def url
      @attributes[:url]
    end

    def name
      @attributes[:name]
    end

    def valid?
      url.present? && Document.valid_url?(url) && name.length <= 255
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
  end
end
