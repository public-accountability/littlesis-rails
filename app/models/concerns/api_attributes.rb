module ApiAttributes
  extend ActiveSupport::Concern

  def api_attributes(options = {})
    ApiUtils::Serializer.new(self, options).attributes
  end
end
