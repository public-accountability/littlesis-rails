# frozen_string_literal: true

# This class represented an edit to an entity. You can think of it as
# a view of the `Versions` table. When a version is created it automatically
# creates a new edited entity class
#
# In some ways this class is similar to Link. It's not intended to be updated directly,
# and there's no harm in deleting the entire table and running `EditedEntity.populate_table`
#
class EditedEntity < ApplicationRecord
  PER_PAGE = 15
  belongs_to :entity, -> { unscope(where: :is_deleted) }
  belongs_to :version, class_name: 'PaperTrail::Version', foreign_key: 'version_id', optional: true
  belongs_to :user, optional: true

  validates :entity_id, presence: true, uniqueness: { scope: :version_id }
  validates :version_id, presence: true
  validates :created_at, presence: true

  def self.recently_edited_entities(page: 1, without_system_users: false, user_id: nil, per_page: PER_PAGE)
    where_clause = if user_id.is_a?(Integer)
                     "WHERE user_id = #{user_id}"
                   elsif without_system_users
                     "WHERE user_id NOT IN (#{User.system_users.map(&:id).join(',')})"
                   end

    EditedEntity.includes(:entity, :user).find_by_sql <<~SQL
      SELECT edited_entities.*
      FROM (
             SELECT max(id) as id, round_five_minutes(created_at) as d
             FROM edited_entities
             #{where_clause}
             GROUP BY entity_id, round_five_minutes(created_at)
             ORDER BY d DESC
             LIMIT #{per_page.to_i}
             OFFSET #{(page - 1) * per_page}
       ) AS subquery
      INNER JOIN edited_entities ON edited_entities.id = subquery.id
    SQL
  end

  # Creates new EditedEntities from a PaperTrail::Version
  # If the verison is for a relationship, two EditedEntities might be created.
  def self.create_from_version(version)
    return unless version.entity_edit?

    user_id = version.whodunnit&.to_i || User.system_user.id

    attributes = { user_id: user_id,
                   version_id: version.id,
                   created_at: version.created_at,
                   entity_id: version.entity1_id }

    EditedEntity.create attributes

    if version.entity2_id.present? && (version.entity2_id != version.entity1_id)
      EditedEntity.create attributes.merge(entity_id: version.entity2_id)
    end
  end

  def self.populate_table
    ApplicationRecord.connection.execute <<~SQL
      INSERT INTO edited_entities (user_id, version_id, entity_id, created_at)
      (SELECT whodunnit::integer, id, entity1_id, created_at FROM versions WHERE entity1_id IS NOT NULL);

      INSERT INTO edited_entities (user_id, version_id, entity_id, created_at)
      (SELECT whodunnit::integer, id, entity2_id, created_at FROM versions WHERE entity2_id IS NOT NULL AND entity2_id != entity1_id);
   SQL
  end
end
