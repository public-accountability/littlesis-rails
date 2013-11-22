module ListsHelper
	def list_link(list, name=nil)
		name ||= list.name
		link_to name, list.legacy_url
	end

	def network_link(list)
		link_to list.name, list.legacy_network_url
	end
end
