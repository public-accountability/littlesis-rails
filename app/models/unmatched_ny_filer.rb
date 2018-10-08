# frozen_string_literal: true

class UnmatchedNyFiler < ApplicationRecord
  # Truncates and re-creates the table
  # by querying ny_filers
  def self.recreate!
    delete_all

    execute_sql <<~SQL
      INSERT INTO #{table_name} (ny_filer_id, disclosure_count)
      SELECT ny_filers.id as ny_filer_id, count(ny_disclosures.id) as disclosure_count
      FROM ny_filers
      LEFT JOIN ny_filer_entities ON ny_filer_entities.ny_filer_id = ny_filers.id
      LEFT JOIN ny_disclosures ON ny_disclosures.filer_id = ny_filers.filer_id
      WHERE ny_filer_entities.id is NULL
      GROUP BY ny_filers.id
    SQL
  end
end
