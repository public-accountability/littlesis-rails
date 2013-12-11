# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

c = Campaign.where(slug: "studentdebt").first_or_create do |campaign|
	campaign.name = "Wall Street Off Campus"
	campaign.tagline = "A tagline for this awesome campaign"
	campaign.description = "This campaign invites students and teachers to investigate the conflict-ridden relationships between schools, education officials, and the financial industry. This campaign invites students and teachers to investigate the conflict-ridden relationships between schools, education officials, and the financial industry.\n\nThis campaign invites students and teachers to investigate the conflict-ridden relationships between schools, education officials, and the financial industry. This campaign invites students and teachers to investigate the conflict-ridden relationships between schools, education officials, and the financial industry."
end

g = Group.where(slug: "harvardwatch").first_or_create do |group|
	group.name = "HarvardWatch"
	group.tagline = "Conscience is the knowledge that someone is watching."
	group.description = "HarvardWatch is a broad-based coalition of students and alumni across the University's schools concerned with corporate governance at Harvard. The independent and unaffiliated organization advocates a more transparent and accountable administration responsive to the concerns of Harvard students, alumni, and staff. HarvardWatch publicizes information about the nature of Harvard's governance system and investments in an effort to improve the functioning of the University; members of HarvardWatch want the University to be the best it can be."
	group.is_private = false
end

g2 = Group.find_by(slug: "occupy")
l = List.find(404) # homepage carousel profiles

if g2.present? and l.present?
	g2.lists << l
	g2.save!

	gl = g2.group_lists.find_by(list_id: 404)
	if gl.present?
		gl.is_featured = true
		gl.save!
	end
end

c.groups << g
c.groups << g2 if g2.present?
c.save!