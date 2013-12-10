module GroupsHelper
	def group_link(group, name=nil)
		name ||= group.name
		link_to name, Rails.application.routes.url_helpers.group_path(id: group.slug)
	end

	def groups_alert(campaign_id=nil)
		dismissable_alert('groups_alert') do
			raw "Research groups allow LittleSis analysts to work together on research projects. If you want to create a group to help you organize a project on LittleSis, please #{link_to 'submit a request', request_new_groups_path(campaign_id: campaign_id)}."
		end
	end
end
