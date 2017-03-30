class LinksGroup

	attr_reader :links, :count, :keyword, :heading, :category_id

	def initialize(links, keyword, heading)
		@keyword = keyword
		@heading = heading
		@category_id = links.empty? ? nil : links[0].category_id 
		@links = group_by_entity(order links)
		@count = @links.count
	end

	def order(links)
	    return links.sort { |a, b| b.related.links.count <=> a.related.links.count } if @category_id == 4
	    return links.sort { |a, b| b.relationship.amount <=> a.relationship.amount } if @category_id == 5
	    return links # Default ordering is end date descending, handled in db query
  	end

  	def group_by_entity(links)
    	links.group_by { |l| l.entity2_id }.values
  	end

end