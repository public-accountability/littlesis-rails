# frozen_string_literal: true

module FECDonorQuery
  def self.run(input)
    search_terms = case input
                   when String, Array
                     Array.wrap(input)
                   when Entity
                     input.name_variations
                   else
                     raise ArgumentError
                   end

    FEC::Donor.find_by_sql(<<~SQL)
      SELECT donors.*
      FROM donor_names
      INNER JOIN donors ON donor_names.rowid = donors.id
      WHERE donor_names MATCH '#{search_terms.join(" OR ")}'
    SQL
  end
end
