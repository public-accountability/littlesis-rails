# frozen_string_literal: true

module FECDonorQuery
  def self.run(search_term)
    FEC::Donor.find_by_sql(<<~SQL)
      SELECT donors.*
      FROM donor_names
      INNER JOIN donors ON donor_names.rowid = donors.id
      WHERE donor_names MATCH '#{search_term}'
    SQL
  end
end
