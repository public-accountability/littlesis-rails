class Oligrapher
  def self.entity_to_node(entity)
    return {
      id: entity.id,
      display: {
        name: entity.name,
        image: node_image(entity),
        url: entity.full_legacy_url
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
    return {
      id: rel.id,
      node1_id: rel.entity1_id,
      node2_id: rel.entity2_id,
      display: {
        label: edge_label(rel),
        arrow: edge_arrow(rel),
        dash: rel.is_current != true
      }
    }
  end

  def self.edge_label(rel)
    return rel.description1 unless rel.description2.present?
    return rel.description2 unless rel.description1.present?
    return rel.description1 if rel.description1 == rel.description2
    rel.category_name
  end

  def self.edge_arrow(rel)
    [ Relationship::POSITION_CATEGORY,
      Relationship::EDUCATION_CATEGORY,
      Relationship::MEMBERSHIP_CATEGORY,
      Relationship::DONATION_CATEGORY,
      Relationship::OWNERSHIP_CATEGORY ].include?(rel.category_id)
  end
end