module ApiAttributes
  extend ActiveSupport::Concern

  class_methods do

    def api_base
      { 'meta' => Api::META }
    end

    def as_api_json(ids)
      api_base.merge({ 'data' => api_data(ids) })
    end

    def api_data(ids)
      find(ids).map(&:api_data)
    end
    
  end

  def as_api_json(route = nil)
    json =  route.present? ? public_send("api_#{route}") : api_json
    api_base.merge(json)
  end
  
  def api_base
    self.class.api_base
  end

  # -> Hash
  def api_json
    json = { 'data' => api_data, 'links' => api_links }
    json.merge!('included' => api_included) unless api_included.blank?
    json
  end

  def api_data
    {
      'type' => self.class.name.tableize.dasherize,
      'id' => id,
      'attributes' => api_attributes
    }
  end

  def api_links
    link = Rails.application.routes.url_helpers.public_send("#{self.class.name.downcase}_url", self)
    { 'self' => link }
  end

  # To return an optional set of included model override this method
  def api_included
  end

  def api_attributes
    ApiUtils::Serializer.new(self).attributes
  end
end
