module Api
  module Serializable
    extend ActiveSupport::Concern

    class_methods do
      def as_api_json(ids)
        Api.as_api_json(find(ids))
      end
    end

    def as_api_json(route: nil, **serializer_options)
      json = route.present? ? public_send("api_#{route}") : api_json(serializer_options)
      api_base.merge(json)
    end

    # Options Hash-> Hash
    def api_json(serializer_options = {})
      json = { 'data' => api_data(serializer_options) }
      json.merge!('included' => api_included) unless api_included.blank?
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
      {'links' => { 'self' => link } }
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

    def api_base
      Api::META_HASH
    end
  end
end
