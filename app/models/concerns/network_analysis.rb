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
        "connecting_entities" => id_hash[:connecting_ids].map { |id| entities_by_id.fetch(id) },
        "stat" => id_hash[:stat]
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
    second_hop_links_for(connection_type)
      .group_by(&:entity2_id)
      .tap { |grouped_ids| grouped_ids.delete(id) } # filter out root id
      .map { |connected_id, links_subset| id_hash_for(connection_type, connected_id, links_subset) }
      .sort { |a, b| b[:connecting_ids].count <=> a[:connecting_ids].count }
  end

  def second_hop_links_for(connection_type)
    Link
      .where(entity1_id:   connecting_ids_for(connection_type),
             category_id:  relationship_categories_for(connection_type),
             is_reverse:   second_hop_link_direction_for(connection_type))
      .to_a
  end

  def connecting_ids_for(connection_type)
    links
      .where(category_id: relationship_categories_for(connection_type),
             is_reverse:  first_hop_link_direction_for(connection_type))
      .pluck(:entity2_id)
  end

  def relationship_categories_for(connection_type)
    {
      interlocks: [Relationship::POSITION_CATEGORY], # (ag|03-Oct-2017): include OWNERSHIP_CATEGORY?
      giving: [Relationship::DONATION_CATEGORY]
    }.fetch(connection_type)
  end

  def first_hop_link_direction_for(connection_type)
    case [connection_type, primary_ext]
    when [:interlocks, "Person"] # get "gives-work-to" position links
      false
    when [:interlocks, "Org"] # get "receives-work from" position links
      true
    when [:giving, "Person"] # get "gives-money-to" donation links
      false
    when [:giving, "Org"] # get "receives-money-from" donation links
      true
    end
  end
  
  def second_hop_link_direction_for(connection_type)
    # this happens to be the inverse of first hop directions
    # for the two operations we currently perform, but we are treating that
    # as coincidental
    case [connection_type, primary_ext]
    when [:interlocks, "Person"] # get "receives-work-from" position links (reverse)
      true
    when [:interlocks, "Org"] # get "gives-work-to" position links (non-reverse)
      false
    when [:giving, "Person"] # get "receivs-money-from" donation links (reverse)
      true
    when [:giving, "Org"] # get "gives-money-to" donation links
      false
    end
  end

  def id_hash_for(connection_type, connected_id, links_subset)
    { connected_id:   connected_id,
      connecting_ids: links_subset.map(&:entity1_id).uniq ,
      stat:           get_stat(connection_type, links_subset) }
  end

  def get_stat(connection_type, links_subset)
    case [connection_type, primary_ext]
    when [:giving, "Org"]
      links_subset.reduce(0) { |acc, link| acc + link.relationship.amount }
      # else nil
    end
  end

  # Array(ConnectedIdHash) => [Integer]
  def collapse(connected_id_hashes)
    connected_id_hashes.map { |x| [x[:connected_id], x[:connecting_ids]] }.flatten.uniq
  end
end
