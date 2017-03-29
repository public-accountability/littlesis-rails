module ApiUtils
  class Serializer
    MODEL_INFO = YAML.load(File.new(Rails.root.join('config', 'api.yml')).read).freeze

    def initialize(model, options = {})
      @model = model
      @options = options
    end

    def attributes
      @attributes = @model.attributes.delete_if { |k, _| attributes_to_ignore.include?(k) }
      model_specific_attributes
      @attributes
    end

    private

    def model_specific_attributes
      case @model
      when Entity
        @attributes['aliases'] = @model.aliases.map(&:name)
        @attributes['types'] = @model.types
        @attributes['extensions'] = @model.extensions_with_attributes if @options[:include_entity_details]
      when ExtensionRecord
        @attributes.merge!(@model.extension_definition.attributes.slice('display_name', 'name'))
      else
      end
    end

    def attributes_to_ignore
      model_ignores = MODEL_INFO[@model.class.name.downcase].try(:fetch, 'ignore')
      return common_ignores if model_ignores.blank?
      common_ignores + model_ignores
    end

    def common_ignores
      MODEL_INFO['common']['ignore']
    end
  end
end
