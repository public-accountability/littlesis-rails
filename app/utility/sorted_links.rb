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

  # input: [ <Link> ] or <Entity>
  def initialize(links_or_entity)
    if links_or_entity.is_a? Entity
      links = preloaded_links(links_or_entity.id)
    else
      links = links_or_entity
    end
    create_subgroups(cull_invalid links)
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

    donors, donation_recipients = split categories[5]
    political_fundraising_committees, donors = donors.partition { |l| l.is_pfc_link? }
    @donors = LinksGroup.new(donors, 'donors', 'Donors')
    @political_fundraising_committees = LinksGroup.new(political_fundraising_committees, 'political_fundraising_committees', 'Political Fundraising Committees')
    @donation_recipients = LinksGroup.new(donation_recipients, 'donation_recipients', 'Donation/Grant Recipients')

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

  private 

  def preloaded_links(entity_id)
    Link.preload(:relationship, related: [:extension_records]).where(entity1_id: entity_id)
  end

  def cull_invalid(links)
    links.select { |l| l.related.present? }
  end

  def split(links)
    links.partition { |l| l.is_reverse == true }
  end
end
