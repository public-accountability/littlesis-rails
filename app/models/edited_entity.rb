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

  # Creates new EditedEntities from a PaperTrail::Version
  # If the verison is for a relationship, two EditedEntities might be created.
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

  # Used to wrap Kaminari::PaginatableArray
  # Provides ways to preload associations
  class Collection < SimpleDelegator
    ASSOCIATIONS = %i[entity version user].freeze

    def preload_all
      ActiveRecord::Associations::Preloader.new.preload(self, ASSOCIATIONS)
    end

    ASSOCIATIONS.each do |association|
      define_method("preload_#{association}") do
        ActiveRecord::Associations::Preloader.new.preload(self, association)
      end
    end
  end

  ###########
  #  Query  #
  ###########

  # Examples
  #
  # To get most recently edited entities by a given user:
  #    EditedEntity::Query.for_user(123).page(1)
  #
  # Most recent edited entities (by anyone):
  #    EditedEntity::Query.all.page(1)
  #
  # Most recent edited entities, changeing the per page
  #    EditedEntity::Query.all.per(50).page(3)
  #
  # Most recent edited entities excluding system users
  #   EditedEntity::Query.without_system_users.page(1)
  #
  # .page() returns a `Collection`
  #
  class Query
    attr_accessor :per_page, :condition

    def initialize(per_page: PER_PAGE, condition: nil)
      @per_page = per_page
      @condition = condition
    end

    def per(per_page)
      @per_page = per_page
      self
    end

    # Integer --> EditedEntited::Collection
    def page(n)
      EditedEntity.recent(page: n, per_page: per_page, condition: condition)
    end

    def self.for_user(user_id)
      condition = EditedEntity.arel_table[:user_id].eq(user_id)
      new(condition: condition)
    end

    def self.without_system_users
      condition = EditedEntity.arel_table[:user_id].not_in(User.system_users.map(&:id))
      new(condition: condition)
    end

    def self.all
      new
    end
  end

  def self.recent(page: 1, per_page: PER_PAGE, condition: nil)
    offset = (page - 1) * per_page
    limit = per_page

    records = find_by_sql(
      self_join_with_grouped_by_entity_id(limit: limit, offset: offset, condition: condition)
    )

    count = total_count_distinct_by_entity_id(condition)

    Collection.new Pagination.paginate(page, per_page, records, count)
  end

  def self.self_join_with_grouped_by_entity_id(limit:, offset:, condition: nil)
    subquery = group_by_entity_id(condition).as('subquery')

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

  def self.group_by_entity_id(condition = nil)
    query = arel_table
              .project(arel_table[:entity_id], arel_table[:version_id].maximum.as('max_version_id'))
              .group(arel_table[:entity_id])

    condition.present? ? query.where(condition) : query
  end

  def self.total_count_distinct_by_entity_id(condition = nil)
    where(condition).select(:entity_id).distinct.count
  end
end
