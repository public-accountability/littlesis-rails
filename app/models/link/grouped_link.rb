# frozen_string_literal: true

class Link
  class GroupedLink
    attr_reader :links
    extend Forwardable
    def_delegators :@links, :first, :length, :each, :map

    def initialize(*links)
      @links = links.sort_by { |l| l.relationship.created_at }.reverse!
    end

    def other_entity(entity)
      first.relationship.other_entity(entity)
    end

    def rest
      @links.drop(1)
    end
  end
end
