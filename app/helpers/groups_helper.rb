module GroupsHelper
	def group_link(group)
		link_to group.name, group
	end
end
