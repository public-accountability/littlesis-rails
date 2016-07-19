# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# c = Campaign.where(slug: "studentdebt").first_or_create do |campaign|
# 	campaign.name = "Wall Street Off Campus" # 
# 	campaign.tagline = "A tagline for this awesome campaign"
# 	campaign.description = "This campaign invites students and teachers to investigate the conflict-ridden relationships between schools, education officials, and the financial industry. This campaign invites students and teachers to investigate the conflict-ridden relationships between schools, education officials, and the financial industry.\n\nThis campaign invites students and teachers to investigate the conflict-ridden relationships between schools, education officials, and the financial industry. This campaign invites students and teachers to investigate the conflict-ridden relationships between schools, education officials, and the financial industry."
# end

# g = Group.where(slug: "harvardwatch").first_or_create do |group|
# 	group.name = "HarvardWatch"
# 	group.tagline = "Conscience is the knowledge that someone is watching."
# 	group.description = "HarvardWatch is a broad-based coalition of students and alumni across the University's schools concerned with corporate governance at Harvard. The independent and unaffiliated organization advocates a more transparent and accountable administration responsive to the concerns of Harvard students, alumni, and staff. HarvardWatch publicizes information about the nature of Harvard's governance system and investments in an effort to improve the functioning of the University; members of HarvardWatch want the University to be the best it can be."
# 	group.is_private = false
# end

# g2 = Group.find_by(slug: "occupy")
# l = List.find(404) # homepage carousel profiles

# if g2.present? and l.present?
# 	g2.lists << l
# 	g2.save!

# 	gl = g2.group_lists.find_by(list_id: 404)
# 	if gl.present?
# 		gl.is_featured = true
# 		gl.save!
# 	end
# end

# c.groups << g
# c.groups << g2 if g2.present?

ExtensionDefinition.create!([
  {name: "Person", display_name: "Person", has_fields: true, parent_id: nil, tier: 1},
  {name: "Org", display_name: "Organization", has_fields: true, parent_id: nil, tier: 1},
  {name: "PoliticalCandidate", display_name: "Political Candidate", has_fields: true, parent_id: 1, tier: 2},
  {name: "ElectedRepresentative", display_name: "Elected Representative", has_fields: true, parent_id: 1, tier: 2},
  {name: "Business", display_name: "Business", has_fields: true, parent_id: 2, tier: 2},
  {name: "GovernmentBody", display_name: "Government Body", has_fields: true, parent_id: 2, tier: 2},
  {name: "School", display_name: "School", has_fields: true, parent_id: 2, tier: 2},
  {name: "MembershipOrg", display_name: "Membership Organization", has_fields: false, parent_id: 2, tier: 2},
  {name: "Philanthropy", display_name: "Philanthropy", has_fields: false, parent_id: 2, tier: 2},
  {name: "NonProfit", display_name: "Other Not-for-Profit", has_fields: false, parent_id: 2, tier: 2},
  {name: "PoliticalFundraising", display_name: "Political Fundraising Committee", has_fields: true, parent_id: 2, tier: 2},
  {name: "PrivateCompany", display_name: "Private Company", has_fields: false, parent_id: 2, tier: 3},
  {name: "PublicCompany", display_name: "Public Company", has_fields: true, parent_id: 2, tier: 3},
  {name: "IndustryTrade", display_name: "Industry/Trade Association", has_fields: false, parent_id: 2, tier: 3},
  {name: "LawFirm", display_name: "Law Firm", has_fields: false, parent_id: 2, tier: 3},
  {name: "LobbyingFirm", display_name: "Lobbying Firm", has_fields: false, parent_id: 2, tier: 3},
  {name: "PublicRelationsFirm", display_name: "Public Relations Firm", has_fields: false, parent_id: 2, tier: 3},
  {name: "IndividualCampaignCommittee", display_name: "Individual Campaign Committee", has_fields: false, parent_id: 2, tier: 3},
  {name: "Pac", display_name: "PAC", has_fields: false, parent_id: 2, tier: 3},
  {name: "OtherCampaignCommittee", display_name: "Other Campaign Committee", has_fields: false, parent_id: 2, tier: 3},
  {name: "MediaOrg", display_name: "Media Organization", has_fields: false, parent_id: 2, tier: 3},
  {name: "ThinkTank", display_name: "Policy/Think Tank", has_fields: false, parent_id: 2, tier: 3},
  {name: "Cultural", display_name: "Cultural/Arts", has_fields: false, parent_id: 2, tier: 3},
  {name: "SocialClub", display_name: "Social Club", has_fields: false, parent_id: 2, tier: 3},
  {name: "ProfessionalAssociation", display_name: "Professional Association", has_fields: false, parent_id: 2, tier: 3},
  {name: "PoliticalParty", display_name: "Political Party", has_fields: false, parent_id: 2, tier: 3},
  {name: "LaborUnion", display_name: "Labor Union", has_fields: false, parent_id: 2, tier: 3},
  {name: "Gse", display_name: "Government-Sponsored Enterprise", has_fields: false, parent_id: 2, tier: 3},
  {name: "BusinessPerson", display_name: "Business Person", has_fields: true, parent_id: 1, tier: 2},
  {name: "Lobbyist", display_name: "Lobbyist", has_fields: true, parent_id: 1, tier: 2},
  {name: "Academic", display_name: "Academic", has_fields: false, parent_id: 1, tier: 2},
  {name: "MediaPersonality", display_name: "Media Personality", has_fields: false, parent_id: 1, tier: 3},
  {name: "ConsultingFirm", display_name: "Consulting Firm", has_fields: false, parent_id: 2, tier: 3},
  {name: "PublicIntellectual", display_name: "Public Intellectual", has_fields: false, parent_id: 1, tier: 3},
  {name: "PublicOfficial", display_name: "Public Official", has_fields: false, parent_id: 1, tier: 2},
  {name: "Lawyer", display_name: "Lawyer", has_fields: false, parent_id: 1, tier: 2},
  {name: "Couple", display_name: "Couple", has_fields: true, parent_id: nil, tier: 1}
])

SfGuardUser.create!({id: 1, username: "system@littlesis.org", password: 'password', salt:''})

List.create!([
  {name: "Buffalo", description: "Powerful individuals in Buffalo, NY, including business, political, and social leaders.", is_ranked: false, is_admin: false, is_featured: false, is_network: true, display_name: "buffalo", featured_list_id: nil,last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false},
  {id: 79, name: "United States", description: "People and organizations with significant influence on the policies of the United States.", is_ranked: false, is_admin: false, is_featured: false, is_network: true, display_name: "us", featured_list_id: nil, last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false},
  {name: "United Kingdom", description: "People and organizations with significant influence on the policies of the United Kingdom.", is_ranked: false, is_admin: false, is_featured: false, is_network: true, display_name: "uk", featured_list_id: nil, last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false},
  {name: "Baltimore", description: "Powerful individuals in Baltimore, MD, including business, political, and social leaders.", is_ranked: false, is_admin: false, is_featured: false, is_network: true, display_name: "baltimore", featured_list_id: nil, last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false},
  {name: "New York State", description: "Powerful individuals in New York State, including business, political, and social leaders.", is_ranked: false, is_admin: false, is_featured: false, is_network: true, display_name: "nys", featured_list_id: nil, last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false},
  {name: "Oakland", description: "Powerful individuals in Oakland, CA, including business, political, and social leaders.", is_ranked: false, is_admin: false, is_featured: false, is_network: true, display_name: "oakland", featured_list_id: nil, last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false}
])

SfGuardPermission.create!([
                            {id: 1, name: "admin", description: "Administrator permission"},
                            {id: 2, name: "contributor", description: nil},
                            {id: 3, name: "editor", description: nil},
                            {id: 5, name: "deleter", description: nil},
                            {id: 6, name: "lister", description: "enables users to create lists"},
                            {id: 7, name: "merger", description: "enables users to merge entities"},
                            {id: 8, name: "importer", description: nil},
                            {id: 9, name: "bulker", description: "enables users to add relationships in bulk"},
                            {id: 10, name: "talker", description: "allows user to use web-based chat"},
                            {id: 11, name: "contacter", description: nil}
                          ])
