# frozen_string_literal: true

module NetworkAnalysis

  # CONSTANTS

  NIL_LAMBDA = ->(_) { nil }

  HOPS = {
    gives_labor_to:  { category_id: Relationship::POSITION_CATEGORY, is_reverse: false },
    gets_labor_from: { category_id: Relationship::POSITION_CATEGORY, is_reverse: true  },
    gives_money_to:  { category_id: Relationship::DONATION_CATEGORY, is_reverse: false },
    gets_money_from: { category_id: Relationship::DONATION_CATEGORY, is_reverse: true  }
  }.freeze

  STATS = [:amount_sum, :connecting_id_count].freeze

  AGGREGATORS_BY_STAT = {
    amount_sum: 'SUM(case when relationship.amount is null then 0 else relationship.amount end)',
    connecting_id_count: 'COUNT(distinct second_hop.entity1_id)'
  }.freeze

  JOINS_BY_STAT = {
    amount_sum: { relationship: true }
  }.freeze

  JOIN_STATEMENTS = {
    relationship: "JOIN relationship on second_hop.relationship_id = relationship.id"
  }.freeze

  PARAMS_BY_QUERY = {
    interlocks_person: {
      hops: [HOPS[:gives_labor_to], HOPS[:gets_labor_from]],
      stat: :connecting_id_count,
      format_stat: ->(s) { s }
    },
    interlocks_org: {
      hops: [HOPS[:gets_labor_from], HOPS[:gives_labor_to]],
      stat: :connecting_id_count,
      format_stat: ->(s) { s }
    },
    similar_donors_person: {
      hops: [HOPS[:gives_money_to], HOPS[:gets_money_from]],
      stat: :connecting_id_count,
      format_stat: ->(s) { s }
    },
    employee_donations_org: {
      hops: [HOPS[:gets_labor_from], HOPS[:gives_money_to]],
      stat: :amount_sum,
      format_stat: ->(s) do
        ActiveSupport::NumberHelper.number_to_currency(s, precision: 0)
      end
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

  # QueryParam, Integer -> [ConnectedEntityHash]
  def connected_nodes(query_params, page = 1)
    id_hashes = connected_ids_via(*query_params.values_at(:hops, :stat))
    paginated_id_hashes = paginate(page, Entity::PER_PAGE, id_hashes)
    entities_by_id = Entity.lookup_table_for(collapse(paginated_id_hashes))

    paginated_id_hashes.map do |id_hash|
      {
        "connected_entity" => entities_by_id.fetch(id_hash["connected_id"]),
        "connecting_entities" => id_hash["connecting_ids"].map { |id| entities_by_id.fetch(id) },
        "stat" => query_params[:format_stat].call(id_hash["stat"])
      }
    end
  end

  # HELPERS

  private

  # [Hop], Symbol -> [ConnectedIdHashd]
  def connected_ids_via(hops, stat)
    sql = <<-SQL
    SELECT second_hop.entity2_id AS connected_id,
           GROUP_CONCAT(distinct second_hop.entity1_id) AS connecting_ids,
           #{AGGREGATORS_BY_STAT[stat]} AS stat
    FROM (
           SELECT DISTINCT entity2_id as first_hop_dest_id
           FROM link
	   WHERE entity1_id = #{id}
                 AND category_id = #{hops.first[:category_id]}
                 AND is_reverse = #{hops.first[:is_reverse]}
    ) as first_hop
    JOIN link as second_hop
          ON first_hop.first_hop_dest_id = second_hop.entity1_id
          AND second_hop.category_id = #{hops.second[:category_id]}
          AND second_hop.is_reverse = #{hops.second[:is_reverse]}
    #{JOIN_STATEMENTS[:relationship] if JOINS_BY_STAT.dig(stat, :relationship)}
    WHERE second_hop.entity2_id <> #{id}
    GROUP BY second_hop.entity2_id
    ORDER BY stat desc
    SQL

    ApplicationRecord.connection.exec_query(sql).to_hash.map { |h| parse_connecting_ids(h) }
  end

  # Hash -> ConnectedIdHash
  def parse_connecting_ids(sql_hash)
    sql_hash.merge!('connecting_ids' => sql_hash.fetch('connecting_ids').split(',').map(&:to_i))
  end

  # [ConnectedIdHash]n -> [Integer]
  def collapse(connected_id_hashes)
    connected_id_hashes.map { |x| [x["connected_id"], x["connecting_ids"]] }.flatten.uniq
  end
end
