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
				# :donors, 
				:donation_recipients, 
				:services_transactions, 
				:lobbying, 
				:friendships, 
				:professional_relationships, 
				:owners, 
				:holdings, 
				:children, 
				:parents, 
				:miscellaneous

	def initialize(links)
		create_subgroups(links)
	end

	def split(links)
		links.partition { |l| l.is_reverse == true }
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
	    # @donors = LinksGroup.new(donors, 'donors', 'Donors')
	    @donation_recipients = LinksGroup.new(donation_recipients, 'donation_recipients', 'Donation/Grant Recipients')

	    @services_transactions = LinksGroup.new(categories[6], 'services_transactions', 'Services/Transactions')
	    @lobbying = LinksGroup.new(categories[7], 'lobbying', 'Lobbying')
	    @friendships = LinksGroup.new(categories[8], 'friendships', 'Friends')
	    @professional_relationships = LinksGroup.new(categories[9], 'professional_relationships', 'Professional Relationships')

	    owners, holdings = split categories[10]
	    @owners = LinksGroup.new(owners, 'owners', 'Owners')
	    @holdings = LinksGroup.new(holdings, 'holdings', 'Holdings')

	    children, parents = split categories[11]
	    @children = LinksGroup.new(children, 'children', 'Child Organizations')
	    @parents = LinksGroup.new(parents, 'parents', 'Parent Organizations')

	    @miscellaneous = LinksGroup.new(categories[12], 'miscellaneous', 'Miscellaneous')
	end

end