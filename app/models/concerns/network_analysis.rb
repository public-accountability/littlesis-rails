module NetworkAnalysis

  # CONSTANTS

  NIL_LAMBDA = ->(_) { nil }

  HOPS = {
    gives_labor_to:  { category_id: Relationship::POSITION_CATEGORY, is_reverse: false },
    gets_labor_from: { category_id: Relationship::POSITION_CATEGORY, is_reverse: true  },
    gives_money_to:  { category_id: Relationship::DONATION_CATEGORY, is_reverse: false },
    gets_money_from: { category_id: Relationship::DONATION_CATEGORY, is_reverse: true  }
  }.freeze

  SORTS = {
    by_connecting_id_count: ->(a, b) { b[:connecting_ids].count <=> a[:connecting_ids].count },
    by_stat: ->(a, b) { b[:stat] <=> a[:stat] }
  }.freeze

  STATS = {
    sum_amounts: ->(ls) { ls.reduce(0) { |acc, link| acc + (link.relationship.amount || 0) } },
  }.freeze

  PARAMS_BY_QUERY = {
    interlocks_person: {
      hops: [HOPS[:gives_labor_to], HOPS[:gets_labor_from]],
      stat: NIL_LAMBDA,
      sort: SORTS[:by_connecting_id_count]
    },
    interlocks_org: {
      hops: [HOPS[:gets_labor_from], HOPS[:gives_labor_to]],
      stat: NIL_LAMBDA,
      sort: SORTS[:by_connecting_id_count]
    },
    similar_donors_person: {
      hops: [HOPS[:gives_money_to], HOPS[:gets_money_from]],
      stat: NIL_LAMBDA,
      sort: SORTS[:by_connecting_id_count]
    },
    employee_donations_org: {
      hops: [HOPS[:gets_labor_from], HOPS[:gives_money_to]],
      stat: STATS[:sum_amounts],
      sort: SORTS[:by_stat]
    }
  }.freeze

  # CLASS METHODS

  def self.query_params_for(query, ext)
    PARAMS_BY_QUERY["#{query}_#{ext.downcase}".to_sym]
  end

  # INSTANCE METHODS

  def interlocks(page = 1)
    connected_nodes(NetworkAnalysis.query_params_for(:interlocks, primary_ext), page)
  end

  def similar_donors(page = 1)
    connected_nodes(NetworkAnalysis.query_params_for(:similar_donors, primary_ext), page)
  end

  def employee_donations(page = 1)
    connected_nodes(NetworkAnalysis.query_params_for(:employee_donations, primary_ext), page)
  end

  # type ConnectedIdHash = { connected_id   => Integer,connecting_ids => [Integer] }
  # [Integer], Integer -> [ConnectedIdHash]
  # TODO(ag|Tue 03 Oct 2017): extract object for this?
  def connected_nodes(qps, page = 1)
    id_hashes = paginate(page, Entity::PER_PAGE, ids_via(*qps.values_at(:hops, :stat, :sort)))
    entities_by_id = Entity.lookup_table_for(collapse(id_hashes))
    id_hashes.map do |id_hash|
      {
        "connected_entity" => entities_by_id.fetch(id_hash[:connected_id]),
        "connecting_entities" => id_hash[:connecting_ids].map { |id| entities_by_id.fetch(id) },
        "stat" => id_hash[:stat]
      }
    end
  end

  # HELPERS

  private

  def ids_via(hops, stat, sort)
    Link
      .joins(:relationship)
      .where(entity1_id:   first_hop_ids(hops.first),
             category_id:  hops.second[:category_id],
             is_reverse:   hops.second[:is_reverse])
      .to_a
      .group_by(&:entity2_id)
      .tap { |grouped_ids| grouped_ids.delete(id) } # filter out root id
      .map { |connected_id, links_subset| id_hash_for(connected_id, links_subset, stat) }
      .sort(&sort)
  end

  def first_hop_ids(hop)
    links
      .where(category_id: hop[:category_id], is_reverse: hop[:is_reverse])
      .pluck(:entity2_id)
  end

  def id_hash_for(connected_id, links_subset, stat)
    { connected_id:   connected_id,
      connecting_ids: links_subset.map(&:entity1_id).uniq,
      stat:           stat.call(links_subset) }
  end

  # [ConnectedIdHash] => [Integer]
  def collapse(connected_id_hashes)
    connected_id_hashes.map { |x| [x[:connected_id], x[:connecting_ids]] }.flatten.uniq
  end
end
