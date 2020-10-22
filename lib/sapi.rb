# frozen_string_literal: true

module Sapi
  FILES = {
    organizations: Rails.root.join('data/sapi_organizations.csv').to_s,
    people: Rails.root.join('data/sapi_individuals.csv').to_s,
    relationships: Rails.root.join('data/sapi_relationships.csv').to_s
  }.freeze

  Location = Struct.new(:city, :state, :country, :region)

  module Models
    Organization = Struct.new(:id, :name, :location, :website, :is_current) do
      def matches
        @matches ||= EntityMatcher.find_matches_for_org(name)
      end

      def littlesis_entity
        @littlesis_entity ||= ExternalLink.sapi.find_by(link_id: id)&.entity
      end
    end

    Person = Struct.new(:id, :name, :first_name, :last_name, :jobtitle, :location, :website, :is_current) do
      def matches
        @matches ||= EntityMatcher.find_matches_for_person(name)
      end

      def littlesis_entity
        @littlesis_entity ||= ExternalLink.sapi.find_by(link_id: id)&.entity
      end
    end

    Relationship = Struct.new(:id, :person_id, :organization_id) do
      def person
        @person ||= Sapi.find_person(person_id)
      end

      def org
        @org ||= Sapi.find_org(organization_id)
      end

      def category_id
        if person&.jobtitle&.present?
          ::Relationship::POSITION_CATEGORY
        else
          ::Relationship::GENERIC_CATEGORY
        end
      end

      def create_new?
        unless person&.littlesis_entity.present? && org&.littlesis_entity.present?
          ColorPrinter.with_logger.print_red "Missing data for relationship #{id}"
          return false
        end

        if (littlesis_r = ::Relationship.find_by(entity: person.littlesis_entity,
                                                 related: org.littlesis_entity,
                                                 category_id: category_id))

          ColorPrinter.print_magenta "Relationship (#{littlesis_r.id}) already exists for #{id}"
          return false
        end

        true
      end
    end
  end

  def self.find_org(id)
    organizations.find { |org| org.id == id }
  end

  def self.find_person(id)
    people.find { |person| person.id == id }
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
      person.website = handle_null(row['Website'])
      person.jobtitle = handle_null(row['JobTitle'])
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
             elsif file == :relationships
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

  def self.import_relationships!
    relationships.each do |r|
      next unless r.create_new?

      littlesis_relationship = ::Relationship.new(entity: r.person.littlesis_entity,
                                                  related: r.org.littlesis_entity,
                                                  category_id: r.category_id)

      if littlesis_relationship.category_id == Relationship::POSITION_CATEGORY
        if r.person.jobtitle.length > 100
          littlesis_relationship.description1 = r.person.jobtitle.tr(r.org.name, '').slice(0, 100)
        else
          littlesis_relationship.description1 = r.person.jobtitle
        end

      end

      littlesis_relationship.save!
    end
  end

  def self.import!
    import_orgs!
    import_people!
    import_relationships!
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
