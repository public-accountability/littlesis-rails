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

    Person = Struct.new(:id, :name, :first_name, :last_name, :jobtitle, :location, :website, :is_current) do
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
      person.location = Location.new(nil, nil, handle_null(row['Country']), handle_null(row['RegionName']))
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

  %i[organizations people relationships].each do |name|
    instance_eval(<<~RUBY)
      def self.#{name}
        @#{name} ||= load_file(:#{name})
      end
    RUBY
  end

  def self.format_organization(org)
    {
      id: org.id,
      name: org.name,
      website: org.website,
      region: org.location.region,
      automatchable: org.matches.automatchable?,
      match_id: org.matches.first&.entity&.id,
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

  def self.format_relationship(relationship)
    {}
  end

  def self.import_orgs!
    organizations.each do |org|
      next if check_for_external_link?(org)

      entity = if org.matches.automatchable?
                 org.matches.first.entity
               else
                 Entity.create!(name: org.name, primary_ext: 'Org')
               end

      update_littlesis_entity(org, entity)
    end
  end

  def self.import_people!
    people.each do |person|
      next if check_for_external_link?(person)

      entity = if person.matches.automatchable?
                 person.matches.first.entity
               elsif person.name.include?(' ')
                 Entity.create!(name: person.name, primary_ext: 'Person')
               else
                 name = "#{person.first_name} #{person.last_name}"
                 Entity.create!(name: name, primary_ext: 'Person')
               end

      update_littlesis_entity(person, entity)
    end
  end

  def self.import!
    import_orgs!
    import_people!
    # import_relationships!
  end

  # Import helpers

  def self.check_for_external_link?(sapi_entity)
    if ExternalLink.sapi.exists?(link_id: sapi_entity.id)
      ColorPrinter.print_red "#{sapi_entity.name} has already been imported"
      true
    else
      ColorPrinter.print_blue "Creating #{sapi_entity.name}"
      false
    end
  end

  def self.should_create_location?(sapi_entity, entity)
    return false if sapi_entity.location.region.blank?

    !entity.locations.pluck(:region).include?(sapi_entity.location.region)
  end

  def self.update_littlesis_entity(sapi_entity, entity)
    entity.external_links.create!(link_type: 'sapi', link_id: sapi_entity.id)
    entity.update!(is_current: sapi_entity.is_current)

    if sapi_entity.website.present? && sapi_entity.website.length <= 100
      entity.update!(website: sapi_entity.website)
    end

    if should_create_location?(sapi_entity, entity)
      entity.locations.create!(region: sapi_entity.location.region)
    end
  end
end
