# frozen_string_literal: true

class EntityConnectionsQuery
  attr_accessor :category_id, :page, :per_page, :excluded_ids, :order
  attr_reader :results

  def initialize(entity)
    @entity = Entity.entity_for(entity)
    @page = 1
    @per_page = 10
    @order = :link_count
  end

  def run
    @results ||= find_by_sql
  end

  def to_oligrapher_nodes
    relationship_ids = run.map(&:connected_relationship_ids).map { |ids| ids.split(',') }.flatten
    relationships = Relationship.lookup_table_for(relationship_ids)

    run.map do |entity|
      Oligrapher::Node.from_entity(entity).tap do |node|
        node[:edges] = relationships
                         .values_at(*entity.connected_relationship_ids.split(',').map(&:to_i))
                         .map(&Oligrapher.method(:rel_to_edge))
      end
    end
  end

  private

  def find_by_sql
    Entity.find_by_sql(<<~SQL)
      SELECT entity.*,
             connected_entities.relationship_ids AS connected_relationship_ids,
             connected_entities.category_id AS connected_category_id
      FROM (
        SELECT links.entity2_id AS entity_id,
              MIN(links.category_id) AS category_id,
              MAX(connected_entity.link_count) AS entity_link_count,
              array_to_string(array_agg(links.relationship_id), ',') AS relationship_ids,
              MAX(relationship.amount) AS relationship_amount,
              bool_or(relationship.is_current) AS relationship_is_current,
              MAX(relationship.start_date) AS relationship_start_date,
              MAX(relationship.updated_at) AS relationship_updated_at
         FROM links
         INNER JOIN relationship ON relationship.id = links.relationship_id
         INNER JOIN entity AS connected_entity ON connected_entity.id = links.entity2_id
         WHERE links.entity1_id = #{@entity.id}
         #{category_sql} #{excluded_ids_sql}
         GROUP BY links.entity2_id
      ) AS connected_entities
      LEFT JOIN entity ON entity.id = connected_entities.entity_id
      ORDER BY #{order_sql}
      LIMIT #{limit}
      OFFSET #{offset}
    SQL
  end

  def order_sql
    case @order.to_sym
    when :link_count
      'connected_entities.entity_link_count DESC'
    when :current
      'connected_entities.relationship_is_current DESC, connected_entities.relationship_start_date DESC'
    when :updated
      'connected_entities.relationship_updated_at DESC'
    when :amount
      'connected_entities.relationship_amount DESC'
    else
      raise Exceptions::ThatsWeirdError, "invalid order selection"
    end
  end

  def category_sql
    "AND links.category_id = #{category}" if category
  end

  def excluded_ids_sql
    if @excluded_ids.present?
      "AND links.entity2_id NOT IN #{ApplicationRecord.sqlize_array(@excluded_ids.map(&:to_i))}"
    end
  end

  def category
    @category_id.to_i if @category_id && (1..12).cover?(@category_id.to_i)
  end

  def limit
    @per_page.to_i
  end

  def offset
    (@page.to_i - 1) * @per_page.to_i
  end
end
