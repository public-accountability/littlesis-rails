# frozen_string_literal: true

class Entity
  # A new version of RelationshipsDatatable
  # Used on the data tab for a searchable page of relationships
  class ConnectionsTable
    extend Forwardable
    attr_reader :entity, :relationships
    def_delegators :@relationships, :each, :length

    def initialize(entity)
      @entity = entity
      @relationships = @entity.relationships.includes(:entity, :related).map do |relationship|
        {
          id: relationship.id,
          category_id: relationship.category_id,
          url: relationship.url,
          other_entity: relationship.other_entity(@entity).attributes.slice('id', 'name', 'blurb', 'url').symbolize_keys!,
          label: relationship.label.label_for_page_of(@entity),
          date_range: relationship.label.display_date_range
        }
      end
    end
  end
end
