# frozen_string_literal: true

module Api
  module Serializable
    extend ActiveSupport::Concern

    class_methods do
      def as_api_json(ids, **options)
        Api.as_api_json(find(ids), **options)
      end
    end

    def as_api_json(route: nil, meta: true, **serializer_options)
      json = route.present? ? public_send("api_#{route}") : api_json(serializer_options)
      meta ? Api::META_HASH.merge(json) : json
    end

    # Options Hash-> Hash
    def api_json(serializer_options = {})
      json = { 'data' => api_data(serializer_options) }
      json['included'] = api_included if api_included.present?
      json
    end

    def api_data(serializer_options = {})
      {
        'type' => self.class.name.tableize.dasherize,
        'id' => id,
        'attributes' => api_attributes(serializer_options)
      }.merge(api_links)
    end

    def api_links
      return {} unless api_linkable?
      link = Rails.application.routes.url_helpers.public_send("#{self.class.name.downcase}_url", self)
      { 'links' => { 'self' => link } }
    end

    # To return an optional set of included model override this method
    def api_included
    end

    def api_attributes(serializer_options = {})
      Api::Serializer.new(self, **serializer_options).attributes
    end

    private

    def api_linkable?
      Api::LINKABLE_CLASSES.include?(self.class.name.downcase.to_sym)
    end
  end
end
