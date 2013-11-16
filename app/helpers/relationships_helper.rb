module RelationshipsHelper
	def rel_link(rel, name=nil)
		name ||= rel.name
		link_to name, rel.legacy_url
	end
end
