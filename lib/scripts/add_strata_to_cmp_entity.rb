#!/usr/bin/env ruby

require 'csv'
require Rails.root.join('lib', 'cmp.rb').to_s

CSV_FILE = Rails.root.join('data', 'cmp_orgs.csv').to_s

Cmp.set_whodunnit do
  CSV.foreach(CSV_FILE, headers: true) do |row|
    cmp_id = row['CMPID_ORGL'].to_i
    cmp_entity = CmpEntity.find_by(cmp_id: cmp_id)
    if cmp_entity
      strata_value = row['TopStrataAlln_2016']
      ColorPrinter.print_green "Adding strata #{strata_value} to CmpEntity\##{cmp_entity.id}"
      cmp_entity.update!(strata: strata_value) unless strata_value.blank?
    else
      ColorPrinter.print_red "Could not find cmp with with cmpid: #{cmp_id}"
    end
  end
end
