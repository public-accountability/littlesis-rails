module ApiAttributes
  extend ActiveSupport::Concern

  def api_attributes
    ApiUtils::Serializer.new(self).attributes
  end
end
