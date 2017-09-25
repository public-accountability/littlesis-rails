module Interlocks
  # extend ActiveSupport::Concern
  def interlocks
    # TODO: create position_scope for Link
    org_ids = links
                .where(entity1_id: id,
                       category_id: Relationship::POSITION_CATEGORY,
                       is_reverse: false)
                .pluck(:entity2_id)

    # [{
    #   person_id => Integer
    #   org_ids => [Integer],
    # }]
    # TODO: extract this and give it more descriptive name for future re-use
    id_hashes = Link
            .where(entity2_id: org_ids,
                   category_id: Relationship::POSITION_CATEGORY,
                   is_reverse: false)
            .to_a
            .group_by(&:entity1_id)
            .tap { |grouped_ids| grouped_ids.delete(id) }
            .map { |person_id, links| { person_id: person_id,
                                        org_ids: links.map(&:entity2_id).uniq } }
            .sort { |a, b| b[:org_ids].count <=> a[:org_ids].count }

    entity_ids = id_hashes.map { |x| [x[:person_id], x[:org_ids]] }.flatten

    entities_by_id = Entity.find(entity_ids).reduce({}) do |acc, entity|
      acc.merge(entity.id => entity)
    end

    id_hashes.map do |id_hash|
      {
        "person" => entities_by_id.fetch(id_hash[:person_id]),
        "orgs" => id_hash[:org_ids].map { |org_id| entities_by_id.fetch(org_id) }
      }
    end
  end
end
