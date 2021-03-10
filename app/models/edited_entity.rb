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
    # PaperTrail::Version.order(id: :asc).find_each do |version|
    #   create_from_version(version)
    # end
    Utility.execute_sql_file Rails.root.join('lib/sql/populate_edited_entities.sql')
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
  # .page() returns an ActiveRecord_Relation
  #
  class Query
    attr_accessor :per_page, :condition

    def initialize(per_page: PER_PAGE, condition: nil, includes: [])
      @per_page = per_page
      @condition = condition
      @includes = includes
    end

    def per(per_page)
      @per_page = per_page
      self
    end

    %i[entity version user].each do |association|
      define_method("include_#{association}") do
        @includes << association unless @includes.include?(association)
        self
      end
    end

    # Integer --> EditedEntited::Collection
    def page(n)
      EditedEntity
        .recent(@condition)
        .includes(@includes)
        .page(n)
        .per(@per_page)
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

  # def self.self_join_with_grouped_by_entity_id(condition: nil)
  def self.recent(condition = nil)
    joins(group_by_entity_id_subquery_for_join(condition))
      .joins(:entity)
      .order(version_id: :desc)
  end

  # This digs DEEP into arel to produces the correct INNER JOIN string
  # Arel::Nodes::Node | nil -->  String
  def self.group_by_entity_id_subquery_for_join(condition = nil)
    subquery = group_by_entity_id(condition).as('subquery')

    arel_table
      .join(subquery).on(
        arel_table[:entity_id].eq(subquery[:entity_id])
          .and(arel_table[:version_id].eq(subquery[:max_version_id]))
      )
      .join_sources
      .first
      .to_sql
  end

  #  Arel::Nodes::Node | nil -->  Arel::SelectManager
  def self.group_by_entity_id(condition = nil)
    query = arel_table
              .project(arel_table[:entity_id], arel_table[:version_id].maximum.as('max_version_id'))
              .group(arel_table[:entity_id])

    condition.present? ? query.where(condition) : query
  end
end
