#!/usr/bin/env -s rails runner

require 'csv'
require_relative '../utility'

# fieds:
#  - incentive
#  - beneficiary_name
#  - approval_date

csvfile = Rails.root.join('data/beneficiarios_de_decretos.csv')
outfile = Rails.root.join('data/beneficiarios_de_decretos-matched.csv')

IAPD_PEOPLE = IapdDatum.all.to_a.filter(&:person?)
IAPD_CORPS = IapdDatum.all.to_a.filter(&:org?)

def person_or_org?(incentive)
  case incentive
  when 'Act 14-2017', 'Act 22-2012'
    :person
  when 'Act 20-2012', 'Act 27-2011', 'Act 273-2012'
    :org
  else
    raise "invalid incentive: #{incentive}"
  end
end

def match_littlesis(name:, type:)
  matcher = EntityMatcher.public_send("find_matches_for_#{type}", name)

  {
    'entity' => matcher.automatch&.entity&.name_with_id,
    'url' => matcher.automatch&.entity&.url,
    'matcher_count' => matcher.count
  }
end

def match_iapd(name:, type:)
  match = nil

  if type == :person
    match = IAPD_PEOPLE.find do |m|
      NameSimilarity::Person.similar?(name, m.row_data['name'])
    end
  elsif type == :org
    match = IAPD_CORPS.find do |m|
      StringSimilarity.similar?(name, m.row_data['name'])
    end
  end

  if match
    { iapd_dataset_key: match.dataset_key, iapd_name: match.row_data['name'] }
  else
    { iapd_dataset_key: nil, iapd_name: nil }
  end
end

rows = []
errors = 0

CSV.read(csvfile, headers: true).map(&:to_h).sample(25).each do |row|
  name = row['beneficiary_name']
  warn "Processing #{name}"

  primary_type = person_or_org? row['incentive']

  iapd = match_iapd name: name, type: primary_type
  littlesis = match_littlesis name: name, type: primary_type

  rows << row.merge(iapd).merge(littlesis)
rescue => 2
  errors += 1
  # STDERR.puts e
end

Utility.save_hash_array_to_csv outfile, rows

ColorPrinter.print_blue "Save to #{outfile}"
ColorPrint.print_red "Found #{errors} errors" if errors.positive?
