module ApiUtils
  # API response builder
  class Response
    include ApiResponseMeta
    include ErrorResponses

    def initialize(model)
      @model = model
      # entity if model_class?(Entity)
    end

    def response
      {
        data: {
          type: @model.class.name.pluralize.downcase,
          id: @model.id,
          attributes: @model.api_attributes,
          links: {
            self: "https://littlesis.org#{@model.legacy_url}"
          }
        },
        meta: self.class.meta
      }
    end

    def to_json(options = {})
      response.to_json
    end

    # symbol -> hash
    def self.error(err)
      {
        errors: [const_get(err)],
        meta: meta
      }
    end

    private

    def model_class?(klass)
      @model.is_of?(klass)
    end
  end
end
