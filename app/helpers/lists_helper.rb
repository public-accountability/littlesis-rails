module ListsHelper
	def list_link(list, name=nil)
		name ||= list.name
		link_to name, list.legacy_url
	end
end
