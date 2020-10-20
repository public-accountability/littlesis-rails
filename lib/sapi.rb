# frozen_string_literal: true

module Sapi
  FILES = {
    organizations: Rails.root.join('data/sapi_organizations.csv').to_s,
    people: Rails.root.join('data/sapi_individuals.csv').to_s
  }.freeze

  Location = Struct.new(:city, :state, :country, :region)

  module Models
    Organization = Struct.new(:id, :name, :location, :website, :is_current) do
      def matches
        @matches ||= EntityMatcher.find_matches_for_org(name)
      end
    end

    Person = Struct.new(:id, :name, :first_name, :last_name, :jobtitle, :region, :country, :website, :is_current) do
      def matches
        @matches ||= EntityMatcher.find_matches_for_person(name)
      end
    end

    Relationship = Struct.new(:id, :person_id, :organization_id)
  end

  def self.handle_null(value)
    value if value.present? && value != 'NULL'
  end

  def self.handle_is_current(value)
    case value
    when 'Active'
      true
    when 'Inactive'
      false
    end
  end

  def self.parse_org(row)
    Models::Organization.new.tap do |organization|
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

  def self.parse_person(row)
    Models::Person.new.tap do |person|
      person.id = row['UniqueIDIndividual']
      person.country = row['Country']
      person.region = row['RegionName']
      person.name = row['FullName']
      person.first_name = row['FirstName']
      person.last_name = row['LastName']
      person.website = row['Website']
    end
  end

  def self.parse_relationship(row)
    Models::Relationship.new(*row.values_at('UniqueIDRelationship', 'UniqueIDIndividual', 'UniqueIDOrganization'))
  end

  def self.load_file(file)
    method = if file == :organizations
               :parse_org
             elsif file == :people
               :parse_person
             elsif fiel == :relatioships
               :parse_relationship
             end

    [].tap do |arr|
      CSV.open FILES.fetch(file), 'r', headers: true do |csv|
        csv.each do |row|
          arr << public_send(method, row)
        end
      end
    end
  end

  def self.format_org(org)
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

  def self.format_person(person)
    {
      id: person.id,
      name: person.name,
      automatchable: person.matches.automatchable?,
      match_name: person.matches.first&.entity&.name_with_id,
      match_url: person.matches.first&.entity&.url,
      match_criteria: person.matches.first&.values&.to_a&.join(',')
    }
  end

  def self.save_organization_automatches
    data = load_file(:organizations)
             .filter { |org| org.matches.automatchable? }
             .map! { |org| format_org(org) }

    filepath = Rails.root.join('sapi_organizations_automatchable.csv')
    ColorPrinter.print_blue "Saving #{data.count} organizations to #{filepath}"
    Utility.save_hash_array_to_csv(filepath, data)
  end

  def self.save_people_automatches
    data = load_file(:people)
             .filter { |p| p.matches.present? }
             .map! { |p| format_person(p) }

    filepath = Rails.root.join('sapi_individuals_with_matches.csv')
    ColorPrinter.print_blue "Saving #{data.count} individuals to #{filepath}"
    Utility.save_hash_array_to_csv(filepath, data)
  end
end
