# frozen_string_literal: true

class Entity
  # [Link::GroupedLinkArray]
  class RelationshipCollection
    PAGE_ORDER= [
      :staff,
      :owners,
      :businesses,
      :board_members,
      :board_memberships,
      :positions,
      :offices,
      :governments,
      :donors,
      :donations,
      :campaign_contributions,
      :campaign_contributors,
      :holdings,
      :children,
      :parents,
      :members,
      :memberships,
      :family,
      :transactions,
      :students,
      :lobbied_by,
      :lobbies,
      :schools,
      :social,
      :generic
    ].freeze

    attr_reader :links
    extend Forwardable
    def_delegators :@links, :each

    def initialize(entity, scope: nil)
      @links = entity
                 .links
                 .where(scope)
                 .includes(:relationship)
                 .to_a
                 .group_by(&:subcategory)
                 .map { |k, v| Link::GroupedLinkArray.new(k, v) }
                 .sort_by! { |x| PAGE_ORDER.index(x) }
    end

    def size
      @size ||= @links.map(&:length).sum
    end

    def get(subcategory)
      @links.find { |x| x.subcategory == subcategory.to_sym }
    end
  end
end
