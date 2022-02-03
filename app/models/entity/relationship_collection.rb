# frozen_string_literal: true

# { "subcategory" => Link::GroupedLinkArray }
class Entity
  class RelationshipCollection
    attr_reader :links
    extend Forwardable
    def_delegators :@links, :[], :each, :fetch, :keys

    def initialize(entity, scope: nil)
      @links = entity
                 .links
                 .where(scope)
                 .includes(:relationship)
                 .to_a
                 .group_by(&:subcategory)
                 .with_indifferent_access
      @links.merge!(@links) { |k, v| Link::GroupedLinkArray.new(k, v) }
    end

    def all
      @links.values
    end

    def size
      @size ||= @links.values.flatten.length
    end
  end
end
