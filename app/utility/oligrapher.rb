# frozen_string_literal: true

module Oligrapher
  DISPLAY_ARROW_CATEGORIES = Set.new([Relationship::POSITION_CATEGORY,
                                      Relationship::EDUCATION_CATEGORY,
                                      Relationship::MEMBERSHIP_CATEGORY,
                                      Relationship::DONATION_CATEGORY,
                                      Relationship::OWNERSHIP_CATEGORY]).freeze

  def self.entity_to_node(entity)
    {
      id: entity.id,
      display: {
        name: entity.name,
        image: entity&.featured_image&.s3_url("profile"),
        url: Routes.entity_url(entity)
      }
    }
  end

  def self.rel_to_edge(rel)
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

  def self.annotation_data(annotation)
    {
      header: annotation.title,
      text: HTMLEntities.new.decode(annotation.description).strip,
      nodeIds: annotation.highlighted_entity_ids.split(","),
      edgeIds: annotation.highlighted_rel_ids.split(","),
      captionIds: annotation.highlighted_text_ids.split(",")
    }
  end

  private_class_method def self.edge_arrow(rel)
    return '1->2' if DISPLAY_ARROW_CATEGORIES.include?(rel.category_id)
  end

  private_class_method def self.relationship_url(relationship)
    Rails.application.routes.url_helpers.relationship_url(relationship)
  end
end
