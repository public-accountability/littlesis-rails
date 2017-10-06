module NetworkAnalysis

  NIL_LAMBDA = ->(_) { nil }

  def interlocks(page = 1)
    connected_nodes(hops_for(:interlocks, primary_ext),
                    get_stat_for(:interlocks, primary_ext),
                    page)
  end

  def similar_donors(page = 1)
    connected_nodes(hops_for(:giving, primary_ext),
                    get_stat_for(:giving, primary_ext),
                    page)
  end

  def employee_donations(page = 1)
    connected_nodes(hops_for(:giving, primary_ext),
                    get_stat_for(:giving, primary_ext),
                    page)
  end

  # type ConnectedIdHash = { connected_id   => Integer,connecting_ids => [Integer] }
  # [Integer], Integer -> [ConnectedIdHash]
  # TODO(ag|Tue 03 Oct 2017): extract object for this?
  def connected_nodes(hops, get_stat = NIL_LAMBDA, page = 1) 
    id_hashes = paginate(page, Entity::PER_PAGE, ids_via(hops, get_stat))
    entities_by_id = Entity.lookup_table_for(collapse(id_hashes))
    id_hashes.map do |id_hash|
      {
        "connected_entity" => entities_by_id.fetch(id_hash[:connected_id]),
        "connecting_entities" => id_hash[:connecting_ids].map { |id| entities_by_id.fetch(id) },
        "stat" => id_hash[:stat]
      }
    end
  end

  private

  def hops_for(connection_type, ext)
    case [connection_type, ext]
    when [:interlocks, "Person"]
      [{ category_id: Relationship::POSITION_CATEGORY, is_reverse: false  }, # "gives-labor-to"
       { category_id: Relationship::POSITION_CATEGORY, is_reverse: true   }] # "gets-labor-from"
    when [:interlocks, "Org"]
      [{ category_id: Relationship::POSITION_CATEGORY, is_reverse: true   }, # "gets-labor-from"
       { category_id: Relationship::POSITION_CATEGORY, is_reverse: false  }] # "gives-labor-to"
    when [:giving, "Person"]
      [{ category_id: Relationship::DONATION_CATEGORY, is_reverse: false  }, # "gives-money-to"
       { category_id: Relationship::DONATION_CATEGORY, is_reverse: true   }] # "gets-money-from"
    when [:giving, "Org"]
      [{ category_id: Relationship::POSITION_CATEGORY, is_reverse: true   }, # "gets-labor-from"
       { category_id: Relationship::DONATION_CATEGORY, is_reverse: false  }] # "gives-money-to"
    end
  end

  def get_stat_for(connection_type, ext)
    case [connection_type, ext]
    when [:giving, "Org"]
      # TODO(ag|05-Oct-2017): Refactor this logic to avoid tons of SQL queries!
      ->(ls) { ls.reduce(0) { |acc, link| acc + (link.relationship.amount || 0) } }
    else
      NIL_LAMBDA
    end
  end

  # TODO(ag|05-Oct-2017): implement this to sort Org Giving tab by stat (summed giving amount)
  def get_sort_for(connection_type, ext); end

  def ids_via(hops, get_stat)
    Link
      .where(entity1_id:   first_hop_ids(hops.first),
             category_id:  hops.second[:category_id],
             is_reverse:   hops.second[:is_reverse])
      .to_a
      .group_by(&:entity2_id)
      .tap { |grouped_ids| grouped_ids.delete(id) } # filter out root id
      .map { |connected_id, links_subset| id_hash_for(connected_id, links_subset, get_stat) }
      .sort { |a, b| b[:connecting_ids].count <=> a[:connecting_ids].count }
      # TODO(ag|05-Oct-2017): use parameterized sort here (but likely in SQL query...)
  end

  def first_hop_ids(hop)
    # TODO(ag|05-Oct-2017):
    # * if we want to extend this to `next_hop_ids`, we could provide `last_hop_id` as param
    # * then query `Link.where(entity1_id: last_hop_id)
    # * worth doing that now, or wait (suspect the latter, curious what @aepyornis thinks...)
    links
      .where(category_id: hop[:category_id], is_reverse: hop[:is_reverse])
      .pluck(:entity2_id)
  end

  def id_hash_for(connected_id, links_subset, get_stat)
    { connected_id:   connected_id,
      connecting_ids: links_subset.map(&:entity1_id).uniq,
      stat:           get_stat.call(links_subset) }
  end

  # [ConnectedIdHash] => [Integer]
  def collapse(connected_id_hashes)
    connected_id_hashes.map { |x| [x[:connected_id], x[:connecting_ids]] }.flatten.uniq
  end
end
