module GroupsHelper
	def group_link(group, name=nil)
		name ||= group.name
		link_to name, group
	end

	def groups_alert
		dismissable_alert('groups_alert') do
			raw "Research groups allow LittleSis analysts to work together on research projects. If you want to create a group to help you organize a project on LittleSis, please #{link_to 'contact us', request_groups_path}."
		end
	end
end
