# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

c = Campaign.create({
	name: "Wall Street Off Campus",
	slug: "studentdebt",
	tagline: "A tagline for this awesome campaign",
	description: "This campaign invites students and teachers to investigate the conflict-ridden relationships between schools, education officials, and the financial industry.\n\nThis campaign invites students and teachers to investigate the conflict-ridden relationships between schools, education officials, and the financial industry."
})

g = Group.create({
	name: "HarvardWatch",
	slug: "harvardwatch",
	tagline: "Conscience is the knowledge that someone is watching.",
	description: "HarvardWatch is a broad-based coalition of students and alumni across the University's schools concerned with corporate governance at Harvard. The independent and unaffiliated organization advocates a more transparent and accountable administration responsive to the concerns of Harvard students, alumni, and staff. HarvardWatch publicizes information about the nature of Harvard's governance system and investments in an effort to improve the functioning of the University; members of HarvardWatch want the University to be the best it can be.",
	is_private: 0
})

c.groups << g
c.save!