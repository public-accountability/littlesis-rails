# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ExtensionDefinition.create!([
  {name: "Person", display_name: "Person", has_fields: true, parent_id: nil, tier: 1},
  {name: "Org", display_name: "Organization", has_fields: true, parent_id: nil, tier: 1}
])

ExtensionDefinition.create!([
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
RelationshipCategory.create!([
  {id: 1, name: "Position", display_name: "Position", default_description: "Position", entity1_requirements: "Person", entity2_requirements: nil, has_fields: true},
  {id: 2, name: "Education", display_name: "Education", default_description: "Student", entity1_requirements: "Person", entity2_requirements: "Org", has_fields: true},
  {id: 3, name: "Membership", display_name: "Membership", default_description: "Member", entity1_requirements: nil, entity2_requirements: nil, has_fields: true},
  {id: 4, name: "Family", display_name: "Family", default_description: "Relative", entity1_requirements: "Person", entity2_requirements: "Person", has_fields: true},
  {id: 5, name: "Donation", display_name: "Donation/Grant", default_description: "Donation/Grant", entity1_requirements: nil, entity2_requirements: nil, has_fields: true},
  {id: 6, name: "Transaction", display_name: "Service/Transaction", default_description: "Service/Transaction", entity1_requirements: nil, entity2_requirements: nil, has_fields: true},
  {id: 7, name: "Lobbying", display_name: "Lobbying", default_description: "Lobbying", entity1_requirements: nil, entity2_requirements: nil, has_fields: true},
  {id: 8, name: "Social", display_name: "Social", default_description: "Social", entity1_requirements: "Person", entity2_requirements: "Person", has_fields: true},
  {id: 9, name: "Professional", display_name: "Professional", default_description: "Professional", entity1_requirements: "Person", entity2_requirements: "Person", has_fields: true},
  {id: 10, name: "Ownership", display_name: "Ownership", default_description: "Owner", entity1_requirements: nil, entity2_requirements: "Org", has_fields: true},
  {id: 11, name: "Hierarchy", display_name: "Hierarchy", default_description: "Hierarchy", entity1_requirements: "Org", entity2_requirements: "Org", has_fields: true},
  {id: 12, name: "Generic", display_name: "Generic", default_description: "Affiliation", entity1_requirements: nil, entity2_requirements: nil, has_fields: true}
])

Degree.create!([
  {id: 1, name: "Doctor of Philosophy", abbreviation: "PhD"},
  {id: 2, name: "Bachelor of Arts", abbreviation: "BA"},
  {id: 3, name: "Master of Business Administration", abbreviation: "MBA"},
  {id: 4, name: "Bachelor of Science", abbreviation: "BS"},
  {id: 5, name: "Juris Doctor", abbreviation: "JD"},
  {id: 6, name: "Bachelor's Degree", abbreviation: nil},
  {id: 7, name: "Bachelor of Laws", abbreviation: "LLB"},
  {id: 8, name: "Master's Degree", abbreviation: nil},
  {id: 9, name: "Master of Science", abbreviation: "MS"},
  {id: 10, name: "Doctorate", abbreviation: nil},
  {id: 11, name: "Associate's Degree", abbreviation: nil},
  {id: 12, name: "Honorus Degree", abbreviation: nil},
  {id: 13, name: "Honorary Doctorate", abbreviation: nil},
  {id: 14, name: "Doctor of Science", abbreviation: "ScD"},
  {id: 15, name: "Master of Arts", abbreviation: "MA"},
  {id: 16, name: "Bachelor of Science in Business Administration", abbreviation: "BSBA"},
  {id: 17, name: "Doctor of Medicine", abbreviation: "MD"},
  {id: 18, name: "Post-Doctoral Training", abbreviation: nil},
  {id: 19, name: "Master of Engineering", abbreviation: "ME"},
  {id: 20, name: "Bachelor of Science in Engineering", abbreviation: "BSE"},
  {id: 21, name: "Bachelor of Engineering", abbreviation: "BE"},
  {id: 22, name: "Associate of Arts", abbreviation: "AA"},
  {id: 23, name: "Associate of Science", abbreviation: "AS"},
  {id: 24, name: "Postgraduate Diploma", abbreviation: nil},
  {id: 25, name: "Drop Out", abbreviation: nil},
  {id: 26, name: "Medical Doctor", abbreviation: nil},
  {id: 27, name: "Registered Nurse", abbreviation: nil},
  {id: 28, name: "Master of Laws", abbreviation: "LLM"},
  {id: 29, name: "Master of Public Administration", abbreviation: nil},
  {id: 30, name: "High School Diploma", abbreviation: nil},
  {id: 31, name: "Doctor of Education", abbreviation: nil},
  {id: 32, name: "Master of Public Policy", abbreviation: nil},
  {id: 33, name: "Bachelor of Science in Economics", abbreviation: nil},
  {id: 34, name: "Bachelor of Science in Finance", abbreviation: nil},
  {id: 35, name: "Certificate", abbreviation: nil},
  {id: 36, name: "Master of Public Health", abbreviation: nil},
  {id: 37, name: "Bachelor of Business Administration", abbreviation: nil},
  {id: 38, name: "Master of International Relations", abbreviation: nil}
])
