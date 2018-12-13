# frozen_string_literal: true

# rubocop:disable Naming/UncommunicativeMethodParamName

# Uses PaperTail::Version to retrive the
# latest entities that have been edited
class EditedEntities
  include Pagination

  PER_PAGE = 20
  # The approximate max number of entities that will retrive.
  HISTORY_LIMIT = 500

  def self.all
    new history_limit: 1000
  end

  def self.user(user_or_id)
    new where: { :whodunnit => Entity.entity_id_for(user_or_id).to_s }
  end

  def initialize(where: nil, per_page: PER_PAGE, history_limit: HISTORY_LIMIT)
    @per_page = per_page
    @where = where
    @history_limit = history_limit
  end

  # Integer --> Kaminari::PaginatableArray of <Entity>
  def page(n = 1)
    paginate(n, @per_page, entities_for_page(n), edited_entities_ids.size)
  end

  # Integer --> [Entity]
  def entities_for_page(n)
    Entity
      .where(id: edited_entities_ids[(@per_page * (n - 1)), @per_page])
      .to_a
  end

  # --> [Integer]
  def edited_entities_ids
    return @_edited_entities_ids if defined?(@_edited_entities_ids)

    @_edited_entities_ids = PaperTrail::Version
                              .where(@where)
                              .where(version_is_for_entity)
                              .order(created_at: :desc)
                              .limit(@history_limit)
                              .pluck(array_of_entity_ids)
                              .map(&entity_id_array_json_to_hash)
                              .flatten
                              .uniq
  end

  private

  # QUERY HELPRS #

  def entity_id_array_json_to_hash
    ->(ids) { JSON.parse(ids).compact }
  end

  def array_of_entity_ids
    Arel.sql <<~SQL
      CASE WHEN item_type = 'Entity' THEN JSON_ARRAY(item_id) ELSE JSON_ARRAY(entity1_id, entity2_id) END
    SQL
  end

  def version_is_for_entity
    version_arel_table[:item_type].eq('Entity')
      .or(version_arel_table[:entity1_id].not_eq(nil))
  end

  def version_arel_table
    PaperTrail::Version.arel_table
  end
end

# rubocop:enable Naming/UncommunicativeMethodParamName
