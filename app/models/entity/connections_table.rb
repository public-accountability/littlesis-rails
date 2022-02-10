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
      @relationships = @entity.relationships.includes(:entity, :related).map { |r| format_relationship(r) }
    end

    def category_collection_for_options
      @relationships
        .map { |h| h[:category_id] }
        .uniq!
        .map { |i| [ RelationshipCategory.lookup.dig(i, :display_name), i] }
    end

    def extension_definition_collection_for_options
      @relationships
        .map { |h| h.dig(:other_entity, :extension_definition_ids) }
        .flatten!
        .uniq!
        .map { |i| [ExtensionDefinition.display_names.fetch(i), i] }
    end

    private

    def format_relationship(relationship)
      {
        id: relationship.id,
        category_id: relationship.category_id,
        is_board: relationship.is_board,
        is_current: relationship.is_current,
        url: relationship.url,
        amount: relationship.amount,
        label: relationship.label.label_for_page_of(@entity),
        date_range: relationship.label.display_date_range,
        other_entity: format_other_entity(relationship.other_entity(@entity))
      }
    end

    # Entity --> Hash
    def format_other_entity(entity)
      entity
        .attributes
        .slice('id', 'name', 'blurb', 'url')
        .symbolize_keys!
        .merge!(extension_definition_ids: entity.extension_definition_ids)
    end
  end
end
