# frozen_string_literal: true

class SortedLinks
  attr_reader :staff,
              :members,
              :memberships,
              :business_positions,
              :government_positions,
              :in_the_office_positions,
              :other_positions,
              :students,
              :schools,
              :family,
              :donors,
              :donation_recipients,
              :political_fundraising_committees,
              :services_transactions,
              :lobbies,
              :lobbied_by,
              :friendships,
              :professional_relationships,
              :owners,
              :holdings,
              :children,
              :parents,
              :miscellaneous

  CATEGORY_SECTIONS = {
    position: %i[business_positions government_positions in_the_office_positions staff other_positions],
    membership: %i[members memberships],
    education: %i[schools students],
    family: %i[family],
    donation: %i[donors donation_recipients political_fundraising_committees],
    transaction: %i[services_transactions],
    lobbying: %i[lobbies lobbied_by],
    friendships: %i[social],
    professional: %i[professional_relationships],
    ownership: %i[owners holdings],
    hierarchy: %i[parents children],
    generic: %i[miscellaneous]
  }.freeze

  SECTION_TO_CATEGORY = Array.new.tap do |array|
    SortedLinks::CATEGORY_SECTIONS.invert.each_pair do |k,v|
      k.each {|w| array << {w => v}}
    end
  end.reduce({}, :merge).freeze

  # input: <Entity>, String, Integer/String, Integer/String
  def initialize(entity, section = nil, page = 1, per_page = 20)
    raise ArgumentError, "SortedLinks must be initialized with a <Entity>" unless entity.is_a? Entity
    @entity = entity
    @page = page.to_i
    @per_page = per_page.to_i

    # If initialized with a section, we only need to load one category
    if section.present?
      create_subgroups(cull_invalid(preloaded_links_for_section(@entity.id, section)))
    elsif entity.link_count > 100
      # For entities with lots of relationships, SortedLinks
      # will execute a different set of SQL statements that
      # loads the donations via it's own optimized query
      @use_separate_donation_query = true
      create_subgroups(cull_invalid(preloaded_links(@entity.id)))
    # However, for most entities with a low link_count, we can just load everything at once:
    else
      @use_separate_donation_query = false
      create_subgroups(cull_invalid(preloaded_links_all(@entity.id)))
    end
  end

  def create_subgroups(links)
    categories = links.group_by { |l| l.category_id }
    categories.default = []

    staff, positions = split categories[RelationshipCategory.name_to_id[:position]]
    members, memberships = split categories[RelationshipCategory.name_to_id[:membership]]
    @staff = LinksGroup.new(staff, 'staff', 'Leadership & Staff')

    @members = LinksGroup.new(members, 'members', 'Members')
    @memberships = LinksGroup.new(memberships, 'memberships', 'Memberships')

    create_position_subgroups(positions)

    students, schools = split categories[RelationshipCategory.name_to_id[:education]]
    @students = LinksGroup.new(students, 'students', 'Students')
    @schools = LinksGroup.new(schools, 'schools', 'Education')

    @family = LinksGroup.new(categories[RelationshipCategory.name_to_id[:family]], 'family', 'Family')

    if @use_separate_donation_query
      create_donation_subgroups
    else
      donors, donation_recipients = split categories[RelationshipCategory.name_to_id[:donation]]
      # political_fundraising_committees, donors = donors.partition { |l| l.is_pfc_link? }
      # @political_fundraising_committees = LinksGroup.new(political_fundraising_committees, 'political_fundraising_committees', 'Political Fundraising Committees')
      @donors = LinksGroup.new(donors, 'donors', 'Donors')
      @donation_recipients = LinksGroup.new(donation_recipients, 'donation_recipients', 'Donation/Grant Recipients')
    end

    @services_transactions = LinksGroup.new(categories[RelationshipCategory.name_to_id[:transaction]], 'services_transactions', 'Services/Transactions')

    lobbied_by, lobbies = split categories[RelationshipCategory.name_to_id[:lobbying]]
    @lobbies = LinksGroup.new(lobbies, 'lobbies', 'Lobbying')
    @lobbied_by = LinksGroup.new(lobbied_by, 'lobbied_by', 'Lobbied By')

    @friendships = LinksGroup.new(categories[RelationshipCategory.name_to_id[:social]], 'friendships', 'Friends')
    @professional_relationships = LinksGroup.new(categories[RelationshipCategory.name_to_id[:professional]], 'professional_relationships', 'Professional Associates')

    owners, holdings = split categories[RelationshipCategory.name_to_id[:ownership]]
    @owners = LinksGroup.new(owners, 'owners', 'Owners')
    @holdings = LinksGroup.new(holdings, 'holdings', 'Holdings')

    children, parents = split categories[RelationshipCategory.name_to_id[:hierarchy]]
    @children = LinksGroup.new(children, 'children', 'Child Organizations')
    @parents = LinksGroup.new(parents, 'parents', 'Parent Organizations')

    @miscellaneous = LinksGroup.new(categories[RelationshipCategory.name_to_id[:generic]], 'miscellaneous', 'Other Affiliations')
  end

  # Sorts position relationships (category 1)
  # by creating these attributes:
  #  - @business_positions
  #  - @government_positions
  #  - @in_the_office_positions
  #  - @other_positions
  def create_position_subgroups(positions)
    jobs = positions.group_by { |l| l.position_type }
    jobs.default = []

    @business_positions = LinksGroup.new(jobs['business'], 'business_positions', 'Business Positions')
    @government_positions = LinksGroup.new(jobs['government'], 'government_positions', 'Government Positions')
    @in_the_office_positions = LinksGroup.new(jobs['office'], 'in_the_office_positions', 'In The Office Of')

    if [@business_positions, @government_positions, @in_the_office_positions].map(&:count).reduce(:+).zero?
      other_heading = 'Positions'
    else
      other_heading = 'Other Positions'
    end

    @other_positions = LinksGroup.new(jobs['other'], 'other_positions', other_heading)
  end

  def create_donation_subgroups
    donors, donation_recipients = split(donation_links_preloaded(@entity.id))
    @donors = LinksGroup.new(donors, 'donors', 'Donors', donors_count(@entity.id))
    @donation_recipients = LinksGroup.new(donation_recipients, 'donation_recipients', 'Donation/Grant Recipients')
  end

  private

  # This returns donations links preloaded with their relationships and related entities
  # Integer -> [ <Link> ]
  def donation_links_preloaded(entity1_id)
    links = donation_links(entity1_id, @page, @per_page) if @page.present? && @per_page.present?
    links = donation_links(entity1_id) unless @page.present? && @per_page.present?
    # Rails doesn't particularly document the use of Associations::Preloader on it's own...but hey...what's stopping us?
    ActiveRecord::Associations::Preloader.new.preload(links, [:relationship, :related])
    links
  end

  # Some politicians have a huge number of political contributions and
  # loading all of their relationships takes a lot of time.
  # This retrieves all donation links (where the entity is the donor)
  # and only *50* donation recipient links, sorted by amount.
  # Integer [, Integer, Integer] -> [ <Link> ]
  def donation_links(entity1_id, page = 1, per_page = 20)
    offset = (page - 1) * per_page

    sql_template = <<~SQL
      ( SELECT links.*, relationships.amount
        FROM links
        INNER JOIN relationships ON relationships.id = links.relationship_id
        WHERE links.entity1_id = ? AND links.category_id = #{RelationshipCategory.name_to_id[:donation]} AND links.is_reverse is false )
      UNION ALL
      ( SELECT links.*, relationships.amount
        FROM relationships
        INNER JOIN links on links.relationship_id = relationships.id and links.entity1_id = ? and links.is_reverse is true
        WHERE relationships.is_deleted is false AND relationships.entity2_id = ? AND relationships.category_id = #{RelationshipCategory.name_to_id[:donation]}
        ORDER by amount desc LIMIT ? OFFSET ? )
    SQL

    Link.find_by_sql([sql_template] + ([entity1_id] * 3) + [per_page] + [offset])
  end

  # Because we are not returning all donation recipient relationships,
  # we need to get a total count for the paginator
  # integer -> integer
  def donors_count(entity1_id)
    Link
      .with_category_name(:donation)
      .where(entity1_id: entity1_id, is_reverse: true)
      .count
  end

  # This preloads relationship, related entities and their extensions for all types except donation (category id = 5)
  def preloaded_links(entity_id)
    Link
      .preload(:relationship, related: [:extension_records])
      .without_category_name(:donation)
      .where(entity1_id: entity_id)
  end

  # This preloads relationship, related entities and entity extensions for all categories
  def preloaded_links_all(entity_id)
    Link.preload(:relationship, related: [:extension_records]).where(entity1_id: entity_id)
  end

  # Returns preloaded links only for the provided section
  def preloaded_links_for_section(entity_id, section)
    if section == 'donors'
      @use_separate_donation_query = true
      donation_links_preloaded(entity_id)
    else
      Link
        .preload(:relationship, related: [:extension_records])
        .with_category_name(SECTION_TO_CATEGORY[section.to_sym])
        .where(entity1_id: entity_id)
    end
  end

  # Removes link where Entity2 is missing
  # Sometimes an Entity will get removed, but will  have dangling links
  def cull_invalid(links)
    links.select { |l| l.related.present? }
  end

  def split(links)
    links.partition { |l| l.is_reverse == true }
  end
end
