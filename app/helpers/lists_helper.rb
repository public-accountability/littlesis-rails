module ListsHelper
	def list_link(list)
		link_to list.name, list
	end
end
