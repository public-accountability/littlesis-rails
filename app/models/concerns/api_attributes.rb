module ApiAttributes
  extend ActiveSupport::Concern

  def api_attributes
    ApiSerializer.new(self).attributes
  end
end
