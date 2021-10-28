# frozen_string_literal: true

module Api
  module Serializable
    extend ActiveSupport::Concern

    class_methods do
      def as_api_json(ids, meta: true)
        Api.as_api_json(find(ids), meta: meta)
      end
    end

    def as_api_json(meta: true, exclude: nil)
      json = api_json(exclude: exclude)
      meta ? Api::META_HASH.merge(json) : json
    end

    # Options Hash-> Hash
    def api_json(exclude: nil, skip_included: false)
      json = { 'data' => api_data(exclude: exclude) }
      json['included'] = api_included if !skip_included && api_included.present?
      json
    end

    def api_data(**options)
      {
        'type' => self.class.name.tableize.dasherize,
        'id' => id,
        'attributes' => api_attributes(**options)
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

    def api_attributes(**options)
      Api::Serializer.new(self, **options).attributes
    end

    private

    def api_linkable?
      Api::LINKABLE_CLASSES.include?(self.class.name.downcase.to_sym)
    end
  end
end
