class LinksGroup

	attr_reader :links, :count, :type

	def initialize(links, type)
		@links = links
		@type = type
		@count = links.count
	end

end