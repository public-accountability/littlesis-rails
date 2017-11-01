module Api
  module Serializable
    extend ActiveSupport::Concern

    class_methods do
      def api_base
        Api::META_HASH
      end

      def as_api_json(ids)
        api_base.merge({ 'data' => api_data(ids) })
      end

      def api_data(ids)
        find(ids).map(&:api_data)
      end
    end

    def as_api_json(route: nil, **serializer_options)
      json = route.present? ? public_send("api_#{route}") : api_json(serializer_options)
      api_base.merge(json)
    end

    def api_base
      self.class.api_base
    end

    # Options Hash-> Hash
    def api_json(serializer_options = {})
      json = { 'data' => api_data(serializer_options), 'links' => api_links }
      json.merge!('included' => api_included) unless api_included.blank?
      json
    end

    def api_data(serializer_options = {})
      {
        'type' => self.class.name.tableize.dasherize,
        'id' => id,
        'attributes' => api_attributes(serializer_options)
      }
    end

    def api_links
      link = Rails.application.routes.url_helpers.public_send("#{self.class.name.downcase}_url", self)
      { 'self' => link }
    end

    # To return an optional set of included model override this method
    def api_included
    end

    def api_attributes(serializer_options = {})
      Api::Serializer.new(self, **serializer_options).attributes
    end
  end
end
