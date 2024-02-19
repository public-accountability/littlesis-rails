#!/usr/bin/env -S rails runner
require 'csv'

# puts Dir[Rails.root.join('data', 'corpu', '*.csv')]
# exit
Universities = {
  'MIT' => 14933,
  'Brown' => 15175,
  'Columbia' => 14924,
  'Cornell' => 15057,
  'Dartmouth' => 15061,
  'Duke' => 15105,
  'FL_State' => 34122,
  'Georgetown' => 15196,
  'Harvard_Corporation' => 267445,
  'Harvard_Overseers' => 402987,
  'Michigan' => 14989,
  'Morgan_St' => 52324,
  'NYU' => 15003,
  'Princeton' => 14950,
  'StJohns' => 33961,
  'Temple' => 15272,
  'UCONN_Foundation' => 142084,
  'UC_Berkeley' => 68692,
  'UC_Regents' => 407075,
  'UC_San_Diego_Foundation' => 48770,
  'UC_Santa_Cruz_Foundation' => 142439,
  'UConn' => 42367,
  'UNC_Chapel_Hill' => 33907,
  'USD' => 34395,
  'U_Penn' => 14957,
  'U_Penn_Wharton' => 14959,
  'Williams' => 15200
}

old_header = ["Name", "Industry", "If Other, what", "Corporate entity", "Position details", "FF-tie Other", "Past", "Notes", "Relevant sources"]
new_headers = ["corpu", "entity_automatch", "entity_name", "entity_id", "entity_url", "other_entity_automatch", "other_entity_name", "other_entity_id", "other_entity_url", "other_entity_existing_relationship"]
headers = old_header + new_headers

output = CSV::Table.new([], headers: headers)

Dir[Rails.root.join('data', 'corpu', '*.csv')].each do |filepath|
  ColorPrinter.print_blue filepath
  corpu = File.basename(filepath, ".csv")
  table = CSV.parse(File.read(filepath), headers: true)

  table.each do |row|
    if row.length != 9
      if row.length == 10
        ColorPrinter.print_red "WARNING removing extra field: #{row[9]}"
      else
        raise StandardError
      end
    end

    new_row = CSV::Row.new(headers, row.fields[0...9])
    new_row['corpu'] = corpu

    begin
      matcher = EntityMatcher.find_matches_for_person(row["Name"], associated: Universities[corpu] )
    rescue ThinkingSphinx::SyntaxError => err
      ColorPrinter.print_red err.message
    end

    new_row['entity_automatch'] = matcher&.automatchable?
    new_row['entity_name'] = matcher&.results&.first&.entity&.name_with_id
    new_row['entity_id'] = matcher&.results&.first&.entity&.id
    new_row['entity_url'] = matcher&.results&.first&.entity&.url

    if row["Corporate entity"].present?
      org_matcher = EntityMatcher.find_matches_for_org(row["Corporate entity"])

      new_row['other_entity_automatch'] = org_matcher.automatchable?
      new_row['other_entity_name'] = org_matcher.results&.first&.entity&.name_with_id
      new_row['other_entity_id'] = org_matcher.results&.first&.entity&.id
      new_row['other_entity_url'] = org_matcher.results&.first&.entity&.url

      if matcher&.automatchable? && org_matcher.automatchable?
        new_row["other_entity_existing_relationship"] = SimilarRelationships.similar_links(
          matcher.results.first.entity.id,
          org_matcher.results.first.entity.id,
          1
        )&.first&.url
      end
    end

    output << new_row

    # rescue StandardError => err
    #   binding.break
  end
end

File.write(Rails.root.join('data', "corpu-results-#{Time.current.strftime('%F')}.csv"), output.to_csv)
