# frozen_string_literal: true

# Class used to retrieve versions and edits for entities
class EntityHistory < RecordHistory
  attr_internal :entity
  delegate :id, to: :entity, prefix: true

  def initialize(entity_or_id)
    self.entity = Entity.entity_for(entity_or_id)
  end

  # int, int -> Kaminari::PaginatableArray
  # Returns paginated array of versions
  # Each version has an extra attribute -- user -- with the User model
  # of the user responsible for the change
  def versions(page: 1, per_page: 15)
    raise ArgumentError unless page.is_a?(Integer) && per_page.is_a?(Integer)
    define_as_presenters(
      add_users_to_versions(
        paginate_versions(page, per_page)
      )
    )
  end

  private

  # add singleton method `as_presenters` which converts each Version to EntityVersionPresenter
  def define_as_presenters(versions)
    versions.tap do |vrs|
      vrs.define_singleton_method(:as_presenters) do
        self.map { |v| EntityVersionPresenter.new(v) }
      end
    end
  end

  # [Array-like] -> [Array-like]
  # add attribute user to each <Version> which the <User> model
  def add_users_to_versions(versions)
    users = User.lookup_table_for versions.map(&:whodunnit).compact.uniq
    entity_for = self.entity

    versions.map do |version|
      version.tap do |v|
        v.singleton_class.class_exec do
          attr_reader :user
          attr_reader :entity
        end
        v.instance_exec do
          @user = users.fetch(v.whodunnit.to_i, nil)
          @entity = entity_for
        end
      end
    end
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
