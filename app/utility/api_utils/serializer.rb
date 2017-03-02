module ApiUtils
  class Serializer
    MODEL_INFO = YAML.load(File.new(Rails.root.join('config', 'api.yml')).read).freeze

    def initialize(model)
      @model = model
      
    end

    def attributes
      @attributes = @model.attributes.delete_if { |k, _| attributes_to_ignore.include?(k) }
      model_specific_attributes
      @attributes
    end

    private

    def model_specific_attributes
      if @model.is_a? Entity
        @attributes['aliases'] = @model.aliases.map(&:name)
        @attributes['types'] = @model.types
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
