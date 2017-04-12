class SortedLinks
  attr_reader :staff,
              :members,
              :business_positions,
              :government_positions,
              :in_the_office_positions,
              :other_positions_and_memberships,
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

  SECTION_TO_CAT = {
    'business_positions' => 1,
    'government_positions' => 1,
    'in_the_office_positions' => 1,
    'staff' => 1,
    'other_positions_and_memberships' => [1,3],
    'schools' => 2,
    'students' => 2,
    'family' => 4,
    'donors' => 5,
    'donation_recipients' => 5,
    'political_fundraising_committees' => 5,
    'services_transactions' => 6,
    'lobbies' => 7,
    'lobbied_by' => 7,
    'friendships' => 8,
    'professional_relationships'=> 9,
    'owners' => 10,
    'holdings' => 10,
    'parents' => 11,
    'children' => 11,      
    'miscellaneous' => 12
  }.freeze

      
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

  def get_other_positions_and_memberships_heading(positions_count, other_positions_count, memberships_count)
    if other_positions_count == 0
      return 'Memberships'
    elsif memberships_count == 0
      if other_positions_count == positions_count
	return 'Positions'
      else
	return 'Other Positions'
      end
    elsif other_positions_count == positions_count
      return 'Positions & Memberships'
    else
      return 'Other Positions & Memberships'
    end
  end

  def create_subgroups(links)
    categories = links.group_by { |l| l.category_id }
    categories.default = []
    
    staff, positions = split categories[1]
    members, memberships = split categories[3]
    @staff = LinksGroup.new(staff, 'staff', 'Office/Staff')
    @members = LinksGroup.new(members, 'members', 'Members')
    
    create_position_subgroups(positions, memberships)

    students, schools = split categories[2]
    @students = LinksGroup.new(students, 'students', 'Students')
    @schools = LinksGroup.new(schools, 'schools', 'Education')

    @family = LinksGroup.new(categories[4], 'family', 'Family')

    if @use_separate_donation_query
       create_donation_subgroups
    else
      donors, donation_recipients = split categories[5]
      # political_fundraising_committees, donors = donors.partition { |l| l.is_pfc_link? }
      # @political_fundraising_committees = LinksGroup.new(political_fundraising_committees, 'political_fundraising_committees', 'Political Fundraising Committees')
      @donors = LinksGroup.new(donors, 'donors', 'Donors')
      @donation_recipients = LinksGroup.new(donation_recipients, 'donation_recipients', 'Donation/Grant Recipients')
    end

    @services_transactions = LinksGroup.new(categories[6], 'services_transactions', 'Services/Transactions')

    lobbied_by, lobbies = split categories[7]
    @lobbies = LinksGroup.new(lobbies, 'lobbies', 'Lobbying')
    @lobbied_by = LinksGroup.new(lobbied_by, 'lobbied_by', 'Lobbied By')

    @friendships = LinksGroup.new(categories[8], 'friendships', 'Friends')
    @professional_relationships = LinksGroup.new(categories[9], 'professional_relationships', 'Professional Associates')

    owners, holdings = split categories[10]
    @owners = LinksGroup.new(owners, 'owners', 'Owners')
    @holdings = LinksGroup.new(holdings, 'holdings', 'Holdings')

    children, parents = split categories[11]
    @children = LinksGroup.new(children, 'children', 'Child Organizations')
    @parents = LinksGroup.new(parents, 'parents', 'Parent Organizations')

    @miscellaneous = LinksGroup.new(categories[12], 'miscellaneous', 'Other Affiliations')
  end

  # Sorts position relationships (category 1) by creating these attributes:
  #  - @business_positions
  #  - @government_positions
  #  - @in_the_office_positions
  #  - @other_positions_and_memberships
  def create_position_subgroups(positions, memberships)
    jobs = positions.group_by { |l| l.position_type }
    jobs.default = []

    @business_positions = LinksGroup.new(jobs['business'], 'business_positions', 'Business Positions')
    @government_positions = LinksGroup.new(jobs['government'], 'government_positions', 'Government Positions')
    @in_the_office_positions = LinksGroup.new(jobs['office'], 'in_the_office_positions', 'In The Office Of')
    other_positions = jobs['other']

    other_heading = get_other_positions_and_memberships_heading(positions.count, other_positions.count, memberships.count)
    @other_positions_and_memberships = LinksGroup.new(other_positions + memberships, 'other_positions_and_memberships', other_heading)
  end

  def create_donation_subgroups
    donors, donation_recipients = split(donation_links_preloaded(@entity.id))
    # political_fundraising_committees, donors = donors.partition { |l| l.is_pfc_link? }
    # @political_fundraising_committees = LinksGroup.new(political_fundraising_committees, 'political_fundraising_committees', 'Political Fundraising Committees')
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
    Link.find_by_sql(
      ["(
          SELECT link.*, relationship.amount
          FROM link
          INNER JOIN relationship ON relationship.id = link.relationship_id
          WHERE link.entity1_id= ? AND link.category_id = 5 AND link.is_reverse = 0
        )
         UNION ALL
        ( 
          SELECT link.*, relationship.amount
          FROM relationship
          INNER JOIN link on link.relationship_id = relationship.id and link.entity1_id = ? and link.is_reverse = 1
          WHERE relationship.is_deleted = 0 AND relationship.entity2_id = ? AND relationship.category_id = 5
          ORDER by amount desc LIMIT ? OFFSET ?
        )"] + ([entity1_id] * 3) + [per_page] + [offset]
    )
  end
  
  # Because we are not returning all donation recipient relationships, 
  # we need to get a total count for the paginator
  # integer -> integer
  def donors_count(entity1_id)
    Link.where(entity1_id: entity1_id, category_id: 5, is_reverse: true).count
  end

  # This preloads relationship, related entities and their extensions for all types except donation (category id = 5)
  def preloaded_links(entity_id)
    Link.preload(:relationship, related: [:extension_records]).where("entity1_id = ? AND category_id <> 5", entity_id)
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
      Link.preload(:relationship, related: [:extension_records]).where(entity1_id: entity_id, category_id: SECTION_TO_CAT[section])
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
