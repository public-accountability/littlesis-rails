# frozen_string_literal: true

class PluralizeSingularTables < ActiveRecord::Migration[6.1]
  SINGULAR_TABLES = %w[alias couple education network_map org political_candidate email position
                       public_company donation image os_category entity address_state
                       lobbyist ownership family elected_representative person
                       business extension_record degree transaction school phone business_person
                       relationship_category extension_definition relationship membership
                       government_body political_fundraising os_entity_category].freeze

  def up
    SINGULAR_TABLES.each do |table|
      rename_table table, table.pluralize
    end
  end

  def down
    SINGULAR_TABLES.each do |table|
      rename_table table.pluralize, table
    end
  end
end
