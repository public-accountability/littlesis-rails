#!/usr/bin/env ruby

require 'csv'

Location = Struct.new(:city, :state, :country, :region)
Organization = Struct.new(:id, :name, :location, :website, :is_current) do
  def matches
    @matches ||= EntityMatcher.find_matches_for_org(name)
  end
end

def handle_null(value)
  value if value.present? && value != 'NULL'
end

def handle_is_current(value)
  case value
  when 'Active'
    true
  when 'Inactive'
    false
  end
end

def parse_row(row)
  Organization.new.tap do |organization|
    organization.id = row['UniqueIDOrganization']
    organization.name = row['OrganizationName']

    organization.location = Location.new(handle_null(row['City']),
                                         handle_null(row['Stateprovince']),
                                         handle_null(row['Country']),
                                         handle_null(row['RegionName']))

    organization.website = handle_null(row['Website'])
    organization.is_current = handle_is_current(row['Status'])
  end
end

# output: Organzation[]
def load_organizations_file
  [].tap do |arr|
    CSV.open Rails.root.join('data/sapi_organizations.csv'), 'r', headers: true do |csv|
      csv.each do |row|
        arr << parse_row(row)
      end
    end
  end
end

def format_org(org)
  {
    id: org.id,
    name: org.name,
    website: org.website,
    region: org.location.region,
    automatchable: org.matches.automatchable?,
    match_name: org.matches.first&.entity&.name_with_id,
    match_url: org.matches.first&.entity&.url,
    match_criteria: org.matches.first&.values&.to_a&.join(',')
  }
end

def run
  organizations = load_organizations_file
  # organizations.filter! { |org| org.matches.present? }
  organizations.filter! { |org| org.matches.automatchable? }
  organizations.map! { |org| format_org(org) }

  filepath = Rails.root.join('sapi_automatchable.csv')
  ColorPrinter.print_blue "Saving #{organizations.count} organizations to #{filepath}"
  Utility.save_hash_array_to_csv(filepath, organizations)
end

run
