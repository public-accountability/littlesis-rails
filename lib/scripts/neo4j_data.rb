# frozen_string_literal: true

# This creates two csvs of entities and relationships,
# designed to be imported in neo4j with LOAD CSV

require 'csv'

COL_SEP = '|'

entity_columns = Entity.columns.map(&:name) - %w[last_user_id delta is_current]
entity_file_path = Rails.root.join('data', 'neo4j', 'entities.csv')

relationship_columns = Relationship.columns.map(&:name) - %w[last_user_id is_current]
relationship_file_path = Rails.root.join('data', 'neo4j', 'relationships.csv')

FileUtils.mkdir_p Rails.root.join('data', 'neo4j').to_s

CSV.open(entity_file_path, 'wb', col_sep: COL_SEP) do |csv|
  csv << entity_columns

  Entity.find_each do |entity|
    csv << entity.attributes.values_at(*entity_columns)
  end
end

CSV.open(relationship_file_path, 'wb', col_sep: COL_SEP) do |csv|
  csv << relationship_columns

  Relationship.find_each do |relationship|
    csv << relationship.attributes.values_at(*relationship_columns)
  end
end
