# frozen_string_literal: true

class Entity
  # A new version of RelationshipsDatatable
  # Used on the data tab for a searchable page of relationships
  class ConnectionsTable
    extend Forwardable
    attr_reader :entity, :relationships
    def_delegators :@relationships, :each, :length, :to_json

    def initialize(entity)
      @entity = entity
      @relationships = @entity.relationships.includes(:entity, :related).map do |relationship|
        {
          id: relationship.id,
          category_id: relationship.category_id,
          is_board: relationship.is_board,
          is_current: relationship.is_current,
          url: relationship.url,
          amount: relationship.amount,
          label: relationship.label.label_for_page_of(@entity),
          date_range: relationship.label.display_date_range[1...-1],
          other_entity: relationship.other_entity(@entity).to_hash(send: :extension_definition_ids).symbolize_keys
        }
      end
    end

    def category_collection_for_options
      @relationships
        .map { |h| h[:category_id] }
        .uniq
        .map { |i| [ RelationshipCategory.lookup.dig(i, :display_name), i] }
    end

    def extension_definition_collection_for_options
      @relationships
        .map { |h| h.dig(:other_entity, :extension_definition_ids) }
        .flatten
        .uniq
        .map { |i| [ExtensionDefinition.display_names.fetch(i), i] }
    end
  end
end
