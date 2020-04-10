# frozen_string_literal: true

module Oligrapher
  VERSION = '36385eefd5ce17574fef6acce8afa596da375145'

  DISPLAY_ARROW_CATEGORIES = Set.new([Relationship::POSITION_CATEGORY,
                                      Relationship::EDUCATION_CATEGORY,
                                      Relationship::MEMBERSHIP_CATEGORY,
                                      Relationship::DONATION_CATEGORY,
                                      Relationship::OWNERSHIP_CATEGORY]).freeze

  def self.configuration(map:, current_user: nil)
    is_owner = current_user.present? && map.user_id == current_user.id

    {
      graph: map.graph_data.to_h,
      settings: { debug: true },
      display: { modes: { editor: is_owner } },
      attributes: {
        id: map.id,
        title: map.title,
        subtitle: '',
        date: (map.created_at || Time.current).strftime('%B %d, %Y'),
        user: { name: current_user&.username },
        settings: {
          private: map.is_private,
          clone: map.is_cloneable,
          defaultStoryMode: false,
          defaultExploreMode: true,
          storyModeOnly: false,
          exploreModeOnly: false
        },
        editors: map.usernames,
        links: [
          { text: 'Edit', url: 'https://littlesis.org/oligrapher/edit' },
          { text: 'Clone', url: 'https://littlesis.org/oligrapher/clone' },
          { text: 'Disclaimer', url: 'https://littlesis.org/oligrapher/disclaimer' }
        ]
      } }
  end

  module Node
    def self.from_entity(entity)
      {
        id: entity.id.to_s,
        name: entity.name,
        description: entity.blurb,
        image: entity.featured_image&.image_url('profile'),
        url: Routes.entity_url(entity)
      }
    end
  end

  def self.rel_to_edge(rel)
    {
      id: rel.id,
      node1_id: rel.entity1_id,
      node2_id: rel.entity2_id,
      label: RelationshipLabel.new(rel).label + (rel.is_current == false ? " (past)" : ""),
      arrow: edge_arrow(rel),
      dash: rel.is_current == false,
      url: relationship_url(rel)
    }
  end

  # Legacy (oligrapher 2.0) functions #

  def self.legacy_entity_to_node(entity)
    {
      id: entity.id,
      display: {
        name: entity.name,
        image: entity&.featured_image&.image_url("profile"),
        url: Routes.entity_url(entity)
      }
    }
  end

  def self.legacy_rel_to_edge(rel)
    {
      id: rel.id, node1_id: rel.entity1_id, node2_id: rel.entity2_id,
      display: {
        label: RelationshipLabel.new(rel).label,
        arrow: edge_arrow(rel),
        dash: rel.is_current != true,
        url: relationship_url(rel)
      }
    }
  end

  private_class_method def self.edge_arrow(rel)
    return '1->2' if DISPLAY_ARROW_CATEGORIES.include?(rel.category_id)
  end

  private_class_method def self.relationship_url(relationship)
    Rails.application.routes.url_helpers.relationship_url(relationship)
  end
end
