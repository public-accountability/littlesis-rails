module NetworkAnalysis

  def interlocks(page = 1)
    id_hashes = paginate(page, Entity::PER_PAGE, connected_id_hashes_for(:interlocks))
    entities_by_id = Entity.lookup_table_for(collapse(id_hashes))
    id_hashes.map do |id_hash|
      {
        "connected_entity" => entities_by_id.fetch(id_hash[:connected_id]),
        "connecting_entities" => id_hash[:connecting_ids].map { |id| entities_by_id.fetch(id) }
      }
    end
  end

  private

  # TODO (ag|Tue 03 Oct 2017): extract object for this?
  # ---
  # type ConnectedIdHash = { connected_id   => Integer,
  #                          connecting_ids => [Integer] }
  # ---
  # [Integer], Integer -> [ConnectedIdHash]
  def connected_id_hashes_for(connection_type)
    Relationship
      .where(connecting_entity_id_key => connecting_ids_for(connection_type),
             :category_id             => relationship_categories_for(connection_type))
      .to_a
      .group_by(&root_entity_id_key)
      .tap { |grouped_ids| grouped_ids.delete(id) } # filter out root id
      .map { |connected_id, rels| connected_id_hash_for(connected_id, rels) }
      .sort { |a, b| b[:connecting_ids].count <=> a[:connecting_ids].count }
  end

  def connecting_ids_for(connection_type)
    relationships
      .where(root_entity_id_key => id, category_id: relationship_categories_for(connection_type))
      .pluck(connecting_entity_id_key)
  end

  def connected_id_hash_for(connected_id, rels)
    {
      connected_id:    connected_id,
      connecting_ids:  connecting_ids_subset_for(rels)
    }
  end

  def connecting_ids_subset_for(relationships)
    relationships.map(&connecting_entity_id_key).uniq
  end

  def relationship_categories_for(connection_type)
    # TODO (ag|03-Oct-2017): include OWNERSHIP_CATEGORY for people interlocks?
    {
      interlocks: [Relationship::POSITION_CATEGORY],
    }.fetch(connection_type)
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
