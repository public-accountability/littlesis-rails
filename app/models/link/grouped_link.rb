# frozen_string_literal: true

class Link
  class GroupedLink
    attr_reader :links
    extend Forwardable
    def_delegators :@links, :first, :length, :each, :map

    def initialize(*links)
      @links = links.sort.reverse!
    end

    def other_entity(entity)
      first.relationship.other_entity(entity)
    end

    # The other GroupedLink needs to be of the same subcategory
    def <=>(other)
      first <=> other.first
    end

    def rest
      @links.drop(1)
    end
  end
end
