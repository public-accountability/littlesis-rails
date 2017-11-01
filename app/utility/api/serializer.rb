module Api
  class Serializer
    attr_reader :attributes
    MODEL_INFO = YAML.load(File.new(Rails.root.join('config', 'api.yml')).read).freeze

    def initialize(model, options = [])
      @model = model
      @options = Array.wrap(options)
      @class_name = @model.class.name.downcase
      @fields = MODEL_INFO.dig @class_name, 'fields'
      @ignore = attributes_to_ignore
      set_attributes
    end

    private

    def set_attributes
      @attributes = @model.attributes.delete_if { |k, _| @ignore.include?(k) }
      model_specific_attributes unless @fields.nil?
      isoify_updated_at
    end

    def model_specific_attributes
      @fields.each do |(field_name, code)|
        @attributes.store(field_name, @model.instance_eval("self.#{code}"))
      end
    end

    def attributes_to_ignore
      model_ignores = MODEL_INFO[@class_name].try(:fetch, 'ignore')
      return common_ignores if model_ignores.blank?
      common_ignores + model_ignores
    end

    def common_ignores
      MODEL_INFO['common']['ignore']
    end

    def isoify_updated_at
      if @model.respond_to?(:updated_at) && @attributes.key?('updated_at')
        @attributes.store('updated_at', @model.updated_at&.iso8601)
      end
    end
  end
end
