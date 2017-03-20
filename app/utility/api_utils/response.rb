module ApiUtils
  # API response builder
  class Response
    include ApiResponseMeta
    include ErrorResponses

    def initialize(model, options = {})
      # Although named with the singular 'model', it can be a collection of models
      @model = model
      @options = options
      @response = response
    end

    # This is the only public instance method, which returns @response as json.
    # The 'options' hash is required by render json: in controllers
    # although we don't any of the options provided
    def to_json(options = {})
      @response.to_json
    end

    # symbol -> hash
    # Accepted symbols:
    #  - RECORD_NOT_FOUND
    #  - RECORD_DELETED
    def self.error(err)
      {
        errors: [const_get(err)],
        meta: meta
      }
    end

    private

    # Toggles between returning a singular response or an array of resopneses
    def response
      if @model.is_a?(Array) || @model.is_a?(ExtensionRecord::ActiveRecord_Relation)
        collection_response
      elsif @model.is_a? ActiveRecord::Base
        singular_response
      else
        raise ArgumentError, "Must be initialized with an ActiveRecord, an Array, or ActiveRecord_Relation. Initialized with a #{@model.class}"
      end
    end

    def collection_response
      {
        data: @model.collect { |m| data_hash(m) },
        meta: self.class.meta
      }
    end

    def singular_response
      {
        data: data_hash,
        meta: self.class.meta
      }
    end

    def data_hash(model = @model)
      hash = {
        type: model.class.name.tableize.dasherize,
        id: model.id,
        attributes: model.api_attributes(@options)
      }
      # Adds the 'links' component only if the model has defined legacy_url.
      # NOTE: We will need to change this later when we no longer use legacy urls
      hash[:links] = self_link(model) if model.respond_to?(:legacy_url)
      hash
    end

    def self_link(model)
      { self: "https://littlesis.org#{model.legacy_url}" }
    end
  end
end
