# frozen_string_literal: true

class ListsIndexQuery
  SORTABLE_COLUMNS = %i[created_at entity_count name].freeze
  def initialize(user_id: nil)
    check_creator_snippet = user_id.present? ? "creator_user_id = #{user_id} OR" : ""
    user_or_private_select = "*, IF(#{check_creator_snippet} access!=#{Permissions::ACCESS_PRIVATE}, 0,1) AS users_or_private"

    @options = {
      select: user_or_private_select,
      with: {users_or_private: 1, is_deleted: false },
      page: 1,
      per_page: 20
    }

    # This creates what seems to be correct sql:
    # SELECT *, IF(creator_user_id = 12 OR access!=2, 0,1) AS users_or_private FROM `list_core` WHERE `users_or_private` = 1 AND `is_deleted` = 0 AND `sphinx_deleted` = 0 LIMIT 0, 20 OPTION cutoff=0

    order_by :created_at
  end

  def only_featured(enable = true)
    @options[:with].merge!(is_featured: true) if enable
    self
  end

  def for_entity(entity_or_id)
    entity = Entity.entity_for(entity_or_id)
    @options[:with] = { id_number: entity.lists.pluck(:id) }
    self
  end

  def order_by(column, direction = :desc)
    unless %i[asc desc].include?(direction) && SORTABLE_COLUMNS.include?(column)
      raise ArgumentError
    end

    # content fields that are sortable require the suffix "_sort"
    column = 'name_sort' if column == :name

    @options[:order] = "#{column} #{direction}"
    self
  end

  def page(n)
    @options[:page] = n.to_i
    self
  end

  def run(query = '')
    List.search(ThinkingSphinx::Query.escape(query), @options)
  end
end
