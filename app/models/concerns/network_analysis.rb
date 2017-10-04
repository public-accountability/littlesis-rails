module NetworkAnalysis
  # extend ActiveSupport::Concern
  def interlocks(page = 1)
    id_hashes = paginate(page, Entity::PER_PAGE, connected_id_hashes)
    entities_by_id = Entity.lookup_table_for(collapse(id_hashes))
    id_hashes.map do |id_hash|
      {
        "connected_entity" => entities_by_id.fetch(id_hash[:connected_id]),
        "connecting_entities" => id_hash[:connecting_ids].map { |id| entities_by_id.fetch(id) }
      }
    end
  end

  private

  def connecting_ids
    relationships
      .where(root_entity_id_key => id, category_id: rel_category_ids)
      .pluck(connecting_entity_id_key)
  end

  # TODO (ag|Tue 03 Oct 2017): extract object for this?
  # ---
  # type ConnectedIdHash = { connected_id   => Integer,
  #                          connecting_ids => [Integer] }
  # ---
  # [Integer], Integer -> [ConnectedIdHash]
  def connected_id_hashes
    Relationship
      .where(connecting_entity_id_key => connecting_ids, category_id: rel_category_ids)
      .to_a
      .group_by(&root_entity_id_key)
      .tap { |grouped_ids| grouped_ids.delete(id) } # filter out root id
      .map { |connected_id, rels| connected_id_hash_for(connected_id, rels) }
      .sort { |a, b| b[:connecting_ids].count <=> a[:connecting_ids].count }
  end

  def connected_id_hash_for(connected_id, rels)
    {
      connected_id:    connected_id,
      connecting_ids:  connecting_ids_for(rels)
    }
  end

  def connecting_ids_for(relationships)
    relationships.map(&connecting_entity_id_key).uniq
  end

  def rel_category_ids
    # TODO (ag|03-Oct-2017):
    # * eventually we would like to include OWNERSHIP_CATEGORY for people
    # * as symphony does not do this and it contradicts the user-facing text
    #   in `EntitiesHelper#entity_interlocks_header_for`, leave this unimplemented for now
    [Relationship::POSITION_CATEGORY]
  end

  def root_entity_id_key
    case primary_ext
    when "Person"
      :entity1_id
    when "Org"
      :entity2_id
    end
  end

  def connecting_entity_id_key
    case primary_ext
    when "Person"
      :entity2_id
    when "Org"
      :entity1_id
    end
  end

  # Array(ConnectedIdHash) => [Integer]
  def collapse(connected_id_hashes)
    connected_id_hashes.map { |x| [x[:connected_id], x[:connecting_ids]] }.flatten.uniq
  end
end
