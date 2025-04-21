#!/usr/bin/env -S rails runner
require 'csv'

old_header = ["name", "entity_tp", "total"]
new_headers = ["entity_automatch", "entity_name", "entity_id", "entity_url"]
headers = old_header + new_headers

output = CSV::Table.new([], headers: headers)

table = CSV.parse(File.read("data/top-2024-donors.csv"), headers: true)

table.each do |row|
  new_row = CSV::Row.new(headers, row.fields[0...7])

  ColorPrinter.print_blue row["name"]

  begin
    if row["entity_tp"] == 'IND'
      matcher = EntityMatcher.find_matches_for_person(row["name"])
    else
      matcher = EntityMatcher.find_matches_for_org(row["name"])
    end
  rescue ThinkingSphinx::SyntaxError => err
    ColorPrinter.print_red err.message
  end

  new_row['entity_automatch'] = matcher&.automatchable?
  new_row['entity_name'] = matcher&.results&.first&.entity&.name_with_id
  new_row['entity_id'] = matcher&.results&.first&.entity&.id
  new_row['entity_url'] = matcher&.results&.first&.entity&.url

  ColorPrinter.print_blue new_row

  output << new_row

  # rescue StandardError => err
  #   binding.break
end

File.write(Rails.root.join('data', "top-2024-fec-donors-results-#{Time.current.strftime('%F')}.csv"), output.to_csv)
