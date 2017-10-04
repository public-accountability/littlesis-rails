module NetworkAnalysis

  def interlocks(page = 1)
    nodes_connected_by_common_neighbor(:interlocks, page)
  end

  def similar_donors(page = 1)
    nodes_connected_by_common_neighbor(:giving, page)
  end

  private

  def nodes_connected_by_common_neighbor(connection_type, page = 1)
    id_hashes = paginate(page, Entity::PER_PAGE, connected_id_hashes_for(connection_type))
    entities_by_id = Entity.lookup_table_for(collapse(id_hashes))
    id_hashes.map do |id_hash|
      {
        "connected_entity" => entities_by_id.fetch(id_hash[:connected_id]),
        "connecting_entities" => id_hash[:connecting_ids].map { |id| entities_by_id.fetch(id) }
      }
    end
  end

  # TODO (ag|Tue 03 Oct 2017): extract object for this?
  # ---
  # type ConnectedIdHash = { connected_id   => Integer,
  #                          connecting_ids => [Integer] }
  # ---
  # [Integer], Integer -> [ConnectedIdHash]
  def connected_id_hashes_for(connection_type)
    connecting_id_key, connecting_ids, category_ids = connection_query_ids_for(connection_type)
    Relationship
      .where( connecting_id_key => connecting_ids, :category_id => category_ids)
      .to_a
      .group_by { |r| r.send(root_entity_id_key_for(connection_type)) }
      .tap { |grouped_ids| grouped_ids.delete(id) } # filter out root id
      .map { |connected_id, rels| connected_id_hash_for(connection_type, connected_id, rels) }
      .sort { |a, b| b[:connecting_ids].count <=> a[:connecting_ids].count }
  end

  def connection_query_ids_for(connection_type)
    [
      connecting_entity_id_key_for(connection_type),
      connecting_ids_for(connection_type),
      relationship_categories_for(connection_type)
    ]
  end

  def connecting_ids_for(connection_type)
    relationships
      .where(root_entity_id_key_for(connection_type) => id,
             category_id: relationship_categories_for(connection_type))
      .pluck(connecting_entity_id_key_for(connection_type))
  end

  def connected_id_hash_for(connection_type, connected_id, rels)
    {
      connected_id:    connected_id,
      connecting_ids:  connecting_ids_subset_for(connection_type, rels)
    }
  end

  def connecting_ids_subset_for(connection_type, relationships)
    relationships
      .map { |r| r.send(connecting_entity_id_key_for(connection_type)) }
      .uniq
  end

  def relationship_categories_for(connection_type)
    # TODO (ag|03-Oct-2017): include OWNERSHIP_CATEGORY for people interlocks?
    {
      interlocks: [Relationship::POSITION_CATEGORY],
      giving: [Relationship::DONATION_CATEGORY]
    }.fetch(connection_type)
  end

  def root_entity_id_key_for(connection_type)
    case [connection_type, primary_ext]
    when [:interlocks, "Person"] # root entity must be employee (eg: entity1)
      :entity1_id
    when [:interlocks, "Org"] # root entity must be employer (eg: entity2)
      :entity2_id
    when [:giving, "Person"] # root entity must be donor (eg: entity1)
      :entity1_id
    end
  end

  def connecting_entity_id_key_for(connection_type)
    case [connection_type, primary_ext]
    when [:interlocks, "Person"] # connecting entity must be employer (eg: entity2)
      :entity2_id
    when [:interlocks, "Org"] # connecting entity must be employee (eg: entity1)
      :entity1_id
    when [:giving, "Person"] # connecting entity must be recipient (eg: entity2)
      :entity2_id
    end
  end

  # Array(ConnectedIdHash) => [Integer]
  def collapse(connected_id_hashes)
    connected_id_hashes.map { |x| [x[:connected_id], x[:connecting_ids]] }.flatten.uniq
  end
end
