# frozen_string_literal: true

module Cmp
  class CmpEntityImporter
    attr_reader :attributes
    delegate :fetch, to: :attributes

    def initialize(attrs)
      @attributes = LsHash.new(attrs)
    end

    def cmpid
      fetch('cmpid')
    end

    protected

    # Symbol -> LsHash
    def attrs_for(model)
      LsHash.new(
        self.class.const_get(:ATTRIBUTE_MAP)
          .select { |_k, (m, _f)| m == model }
          .map { |k, (_m, f)| [f, attributes[k]] }
          .to_h
      )
    end

    private

    def entity_url(entity)
      primary_ext = self.class.name.gsub('Cmp::Cmp', '').downcase
      e_path = Rails.application.routes.url_helpers.entity_path(entity).gsub('entities', primary_ext)
      "https://littlesis.org#{e_path}"
    end
  end
end
