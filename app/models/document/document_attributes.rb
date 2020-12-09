# frozen_string_literal: true

class Document
  class DocumentAttributes
    attr_reader :url, :name

    def initialize(attrs)
      @url = attrs[:url] || attrs['url']
      @name = attrs[:name] || attrs['name'] || @url&.slice(0, 255)
      freeze
    end

    def to_h
      { url: @url, name: @name }
    end

    def valid?
      @url.present? && Document.valid_url?(@url) && @name.length <= 255
    end

    def error_message
      if @url.blank?
        'A source URL is required'
      elsif !Document.valid_url?(@url)
        "\"#{@url}\" is not a valid url"
      elsif @name.length >= 255
        'Name is too long'
      end
    end
  end
end
