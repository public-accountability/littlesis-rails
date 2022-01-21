# frozen_string_literal: true

# ThinkingSphinx::Query.escape

class ListsIndexQuery
  SEARCHABLE_COLUMNS = %i[created_at entity_count].freeze

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
    unless %i[asc desc].include?(direction) && SEARCHABLE_COLUMNS.include?(column)
      raise ArgumentError
    end

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
