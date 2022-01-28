# frozen_string_literal: true

class Entity
  class RelationshipCollection
    attr_reader :links
    extend Forwardable
    def_delegators :@links, :[], :each

    def initialize(entity)
      @links = entity
                 .links
                 .includes(:relationship)
                 .to_a
                 .group_by(&:subcategory)
                 .with_indifferent_access
                 .transform_values! { |v| Link::GroupedLink.create(v) }
    end

    def all
      @links.values
    end
  end
end
