# Class used to retrieve versions and edits for entities
class EntityHistory
  include Pagination
  attr_internal :entity
  delegate :id, to: :entity, prefix: true

  def initialize(entity_or_id)
    self.entity = Entity.entity_for(entity_or_id)
  end

  # int, int -> Kaminari::PaginatableArray
  # Returns paginated array of versions
  # Each version has an extra attribute -- user -- with the User model
  # of the user responsible for the change
  def versions(page: 1, per_page: 20)
    raise ArgumentError unless page.is_a?(Integer) && per_page.is_a?(Integer)
    add_users_to_versions(
      paginate(
        page,
        per_page,
        versions_for(page: page, per_page: per_page),
        versions_count
      )
    )
  end

  private

  # [Array-like] -> [Array-like]
  # add attribute user to each <Version> which the <User> model
  # add singleton method `as_presenters` which converts each Version to EntityVersionPresenter
  def add_users_to_versions(versions)
    users = User.lookup_table_for versions.map(&:whodunnit).compact.uniq

    versions.map do |version|
      version.tap do |v|
        v.singleton_class.class_exec { attr_reader :user }
        v.instance_exec { @user = users.fetch(v.whodunnit.to_i, nil) }
      end
    end.tap do |vrs|
      vrs.define_singleton_method(:as_presenters) do
        self.map { |v| EntityVersionPresenter.new(v) }
      end
    end
  end

  # int, int -> Array[Version]
  # returns PaperTrail::Version models, ordered by most recent
  def versions_for(page:, per_page:)
    PaperTrail::Version.find_by_sql(versions_paginated_sql(page: page, per_page: per_page))
  end

  # -> integer
  # total count of all versions for the entity
  def versions_count
    ApplicationRecord.execute_one versions_sql(select: 'COUNT(*)', order: '')
  end

  # int, int -> str
  # paginated sql of versions query
  def versions_paginated_sql(page:, per_page:)
    "#{versions_sql} LIMIT #{per_page} OFFSET #{(page - 1) * per_page}"
  end

  # str, str -> str
  # SQL statement to extract version for the entity
  # It includes version for models (such as Relationship and Alias)
  # that have been marked as associated with this entity via the entity1_id field
  def versions_sql(select: '*', order: 'ORDER BY created_at DESC')
    <<~SQL
      SELECT #{select}
      FROM versions
      WHERE (item_id = #{entity_id} AND item_type = 'Entity')
         OR (entity1_id = #{entity_id})
         OR (entity2_id = #{entity_id})
      #{order}
    SQL
  end
end
