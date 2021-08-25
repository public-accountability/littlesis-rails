# frozen_string_literal: true

class ListInterlocksQuery
  attr_reader :results

  def initialize(list)
    @list = list
  end

  def run
    @results ||= interlocks_sql
  end

  private

  def interlocks_sql
    # get people in the list
    entity_ids = @list.entities.people.map(&:id)

    sql = <<~SQL.squish
      SELECT  entities.*, subquery.num as num, subquery.degree1_ids as degree1_ids
      FROM (
       SELECT relationships.entity2_id as entity_id,
              COUNT(DISTINCT relationships.entity1_id) as num,
              array_to_string(array_agg(DISTINCT relationships.entity1_id), ',') degree1_ids
       FROM relationships
       LEFT JOIN entities ON (entities.id = relationships.entity2_id)
       WHERE relationships.entity1_id IN ( #{entity_ids.join(',')} ) AND (relationships.category_id = #{RelationshipCategory.name_to_id[:position]} OR  relationships.category_id = #{RelationshipCategory.name_to_id[:membership]}) AND relationships.is_deleted is false
       GROUP BY relationships.entity2_id ) AS subquery
      INNER JOIN entities on entities.id = subquery.entity_id
      ORDER BY num desc
    SQL

    Entity.includes(:extension_definitions).find_by_sql(sql)
  end
end
