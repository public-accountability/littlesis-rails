# frozen_string_literal: true

module Cmp
  class CmpEntityImporter
    attr_reader :attributes, :cmpid
    delegate :fetch, to: :attributes

    def initialize(attrs)
      @attributes = attrs.dup.with_indifferent_access
      @cmpid = @attributes.fetch('cmpid')
    end

    protected

    # Symbol -> Hash
    def attrs_for(model)
      self.class.const_get(:ATTRIBUTE_MAP)
        .select { |_k, (m, _f)| m == model }
        .map { |k, (_m, f)| [f, attributes[k]] }
        .to_h
        .delete_if { |_k, v| v.nil? }
        .with_indifferent_access
    end

    private

    def entity_url(entity)
      primary_ext = self.class.name.gsub('Cmp::Cmp', '').downcase
      e_path = Rails.application.routes.url_helpers.entity_path(entity).gsub('entities', primary_ext)
      "https://littlesis.org#{e_path}"
    end
  end
end
