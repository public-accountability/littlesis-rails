# frozen_string_literal: true

# This class represented an edit to an entity. You can think of it as
# a view of the `Versions` table. When a version is created it automatically
# creates a new edited entity class
#
# In some ways this class is similar to Link. It's not intended to be updated directly,
# and there's no harm in deleting the entire table and running `EditedEntity.populate_table`
#
class EditedEntity < ApplicationRecord
  PER_PAGE = 20
  belongs_to :entity
  belongs_to :version, class_name: 'PaperTrail::Version', foreign_key: 'version_id', optional: true
  belongs_to :user, optional: true

  validates :entity_id, presence: true, uniqueness: { scope: :version_id }
  validates :version_id, presence: true
  validates :created_at, presence: true

  ######################
  # Creating functions #
  ######################

  def self.create_from_version(version)
    return unless version.entity_edit?

    base_attributes = { user_id: version.whodunnit&.to_i,
                        version_id: version.id,
                        created_at: version.created_at }

    EditedEntity.create base_attributes.merge(entity_id: version.entity1_id)

    if version.entity2_id.present? && (version.entity2_id != version.entity1_id)
      EditedEntity.create base_attributes.merge(entity_id: version.entity2_id)
    end
  end

  def self.populate_table
    PaperTrail::Version.order(id: :asc).find_each do |version|
      create_from_version(version)
    end
  end

  ##########
  # Query  #
  ##########

  def self.recent(page: 1, per_page: PER_PAGE, user_id: nil)
    offset = (page - 1) * per_page
    limit = per_page

    records = find_by_sql(
      self_join_with_grouped_by_entity_id(limit: limit, offset: offset, user_id: user_id)
    )

    count = total_count_distinct_by_entity_id(user_id.present? ? { :user_id => user_id } : nil)

    Pagination.paginate(page, per_page, records, count)
  end

  def self.user(user_id, **kwargs)
    TypeCheck.check user_id, Integer

    recent(**kwargs.merge(user_id: user_id))
  end

  def self.self_join_with_grouped_by_entity_id(limit:, offset:, user_id: nil)
    subquery = group_by_entity_id(user_id: user_id).as('subquery')

    arel_table
      .project(Arel.star)
      .join(subquery).on(
        arel_table[:entity_id].eq(subquery[:entity_id])
          .and(arel_table[:version_id].eq(subquery[:max_version_id]))
      )
      .order(arel_table[:version_id].desc)
      .take(limit)
      .skip(offset)
  end

  def self.group_by_entity_id(user_id: nil)
    query = arel_table
              .project(arel_table[:entity_id], arel_table[:version_id].maximum.as('max_version_id'))
              .group(arel_table[:entity_id])

    user_id.present? ? query.where(arel_table[:user_id].eq(user_id)) : query
  end

  def self.total_count_distinct_by_entity_id(where = nil)
    where(where).select(:entity_id).distinct.count
  end
end
