class Oligrapher
  def self.entity_to_node(entity)
    {
      id: entity.id,
      display: {
        name: entity.name,
        image: node_image(entity),
        url: entity_url(entity)
      }
    }
  end

  def self.node_image(entity)
    if image = entity.featured_image
      return image.s3_url("profile")
    end

    nil
  end

  def self.rel_to_edge(rel)
    {
      id: rel.id,
      node1_id: rel.entity1_id,
      node2_id: rel.entity2_id,
      display: {
        label: edge_label(rel),
        arrow: edge_arrow(rel),
        dash: rel.is_current != true,
        url: rel.full_legacy_url
      }
    }
  end

  def self.edge_label(rel)
    return rel.description1 if rel.description1.present? and !rel.description2.present?
    return rel.description2 if rel.description2.present? and !rel.description1.present?
    return rel.description1 if rel.description1 == rel.description2 and rel.description1.present?
    rel.category_name
  end

  def self.edge_arrow(rel)
    [ Relationship::POSITION_CATEGORY,
      Relationship::EDUCATION_CATEGORY,
      Relationship::MEMBERSHIP_CATEGORY,
      Relationship::DONATION_CATEGORY,
      Relationship::OWNERSHIP_CATEGORY ].include?(rel.category_id)
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

  private_class_method def self.entity_url(entity)
    Routes.modify_entity_path(Rails.application.routes.url_helpers.entity_url(entity), entity)
  end
end
