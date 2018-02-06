# Class used to retrive versions and edits
# for entities
class EntityHistory
  include Pagination
  attr_internal :entity
  delegate :id, to: :entity, prefix: true

  def initialize(entity_or_id)
    self.entity = Entity.entity_for(entity_or_id)
  end

  def versions(page: 1, per_page: 20)
    raise ArgumentError unless page.is_a?(Integer) && per_page.is_a?(Integer)
    paginate(
      page,
      per_page,
      PaperTrail::Version.find_by_sql(versions_paginated(page: page, per_page: per_page)),
      versions_count
    )
  end

  private

  def versions_paginated(page:, per_page:)
    "#{versions_sql} LIMIT #{per_page} OFFSET #{(page - 1) * per_page}"
  end

  def versions_count
    ApplicationRecord.execute_one versions_sql(select: 'COUNT(*)', order: '')
  end

  def versions_sql(select: '*', order: 'ORDER BY created_at DESC')
    <<~SQL
      SELECT #{select}
      FROM versions
      WHERE
        (item_id = #{entity_id} AND item_type = 'Entity')
      OR
        (entity1_id = #{entity_id})
      #{order}
    SQL
  end
end
