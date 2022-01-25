# frozen_string_literal: true

class ListsIndexQuery
  SORTABLE_COLUMNS = %i[created_at entity_count name].freeze

  def initialize
    @options = {
      with: { is_deleted: false },
      without: { access: Permissions::ACCESS_PRIVATE },
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
