# frozen_string_literal: true

module Api
  class Serializer
    MODEL_INFO = YAML.safe_load(File.new(Rails.root.join('config', 'api.yml')).read).with_indifferent_access.freeze

    extend Forwardable
    attr_reader :attributes

    def_delegator :@attributes, :[], :to_h

    def initialize(model, exclude: nil)
      @model = model
      @model_info = MODEL_INFO[@model.class.name.downcase] || {}
      # Common Fields + model-specific fields defined in api.yml + method argument
      @ignore = MODEL_INFO[:common][:ignore].dup
      @ignore.concat(@model_info[:ignore]) if @model_info[:ignore]
      @ignore.concat(Array.wrap(exclude).map(&:to_s)) if exclude.present?

      @attributes = @model.attributes

      # Some models have additional fields defined in api.yml
      @model_info[:fields]&.each do |(field_name, code)|
        @attributes.store(field_name.to_s, @model.instance_eval("self.#{code}"))
      end

      @attributes.delete_if { |k| @ignore.include?(k) }

      if @model.respond_to?(:updated_at) && @attributes.key?('updated_at')
        @attributes.store('updated_at', @model.updated_at&.iso8601)
      end
    end
  end
end
