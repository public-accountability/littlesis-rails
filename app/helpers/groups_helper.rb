module GroupsHelper
	def group_link(group, name=nil)
		name ||= group.name
		link_to name, group
	end
end
