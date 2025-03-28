# frozen_string_literal: true

class ListsIndexQuery
  SORTABLE_COLUMNS = %i[created_at entity_count name].freeze
  def initialize(user_id: nil)
    check_creator_snippet = user_id.present? ? "creator_user_id = #{user_id} OR" : ""
    users_or_not_private_select = "*, IF(#{check_creator_snippet} access!=#{Permissions::ACCESS_PRIVATE}, 1,0) AS users_or_not_private"

    @options = {
      select: users_or_not_private_select,
      with: {users_or_not_private: 1, is_deleted: false },
      page: 1,
      per_page: 20
    }
    order_by :created_at
  end

  def only_featured(enable = true)
    @options[:with].merge!(is_featured: true) if enable
    self
  end

  def for_entity(entity_or_id)
    entity = Entity.entity_for(entity_or_id)
    @options[:with] = @options[:with].merge(id_number: entity.lists.pluck(:id))
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
