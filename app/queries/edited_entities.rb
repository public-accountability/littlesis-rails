# frozen_string_literal: true

# rubocop:disable Naming/UncommunicativeMethodParamName

# Using +PaperTail::Version+, this class retrieves
# entities that have been edited recently.
#
# Edits are tracked using paper_tail using the versions table. Edits that are directly
# on the Entity model can be found by searching version with item_type "Entity".
# However, there are a lot of related models that, indirectly, are still considered
# to be an "edit" of the entity. Those models will have metadata stored with the version
# in two columns: entity1_id and entity2_id. Edits to "Relationships" utilize both columns
# while other models (such as "Person") use only entity1_id. Additionally, the same
# entity is often edited multiple times in a row. Because of the usual nature of
# this setup, the queries and pagaination for this class might look a little funny.
class EditedEntities
  include Pagination

  delegate :recent_entity_edits, to: :class

  PER_PAGE = 20
  # The approximate max number of entities that will be retrieved
  HISTORY_LIMIT = 500

  def self.all
    new history_limit: 1000
  end

  def self.user(user_or_id)
    user_id = user_or_id.is_a?(User) ? user_or_id.id : user_or_id
    new user_id: user_id
  end

  # --> [Hash]
  # See lib/sql/recent_entity_edit.sql for the function/query this method calls
  def self.recent_entity_edits(user_id:, history_limit:)
    TypeCheck.check user_id, Integer, allow_nil: true
    TypeCheck.check history_limit, Integer

    user_id_for_sql = user_id.nil? ? 'NULL' : "'#{user_id}'"
    sql = "SELECT recent_entity_edits(#{history_limit}, #{user_id_for_sql})"

    JSON.parse ApplicationRecord.execute_one(sql)
  end

  def initialize(user_id: nil, per_page: PER_PAGE, history_limit: HISTORY_LIMIT)
    @per_page = per_page
    @user_id = user_id
    @history_limit = history_limit
  end

  # Integer --> Kaminari::PaginatableArray of <Entity>
  def page(n = 1)
    paginate(n, @per_page, entity_collection(n), edited_entities.size)
  end

  def entity_collection(n)
    slice = edited_entities[(@per_page * (n - 1)), @per_page]
    return [] if slice.nil? || slice.length.zero?

    entities = Entity.lookup_table_for(slice.map { |h| h['entity_id'] }, ignore: true)
    users = User.lookup_table_for(slice.map { |h| h['user_id'] }, ignore: true)

    slice.map do |hash|
      hash.tap do |h|
        h.store 'entity', entities.fetch(h['entity_id'], nil)
        h.store 'user', users.fetch(h['user_id'], nil)
      end
    end
  end

  # --> [EntityEditHash]
  def edited_entities
    return @_edited_entities if defined?(@_edited_entities)

    @_edited_entities = recent_entity_edits(user_id: @user_id, history_limit: @history_limit)
                          .uniq { |h| h['entity_id'] }
  end
end

# rubocop:enable Naming/UncommunicativeMethodParamName
