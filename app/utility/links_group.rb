# frozen_string_literal: true

class LinksGroup
  attr_reader :links, :count, :keyword, :heading, :category_id

  # input: [ <Link> ] , str, str, integer
  # Assumes that the links all have the same category
  def initialize(links, keyword, heading, count = nil)
    @keyword = keyword
    @heading = heading
    @category_id = links.empty? ? nil : links[0].category_id
    @links = group_by_entity(order(links))
    # In situations where the array size does not represent the total count, i.e. queries with LIMIT
    if count.present?
      @count = count
    else
      # The count here represents not the total amount of all relationships but the grouped count.
      # If there are 4 links with the same person (i.e. entity2 is same) then @count will be 1
      @count = @links.count
    end
  end

  def order(links)
    # return links.sort { |a, b| b.related.links.count <=> a.related.links.count } if @category_id == 4
    return links.sort_by { |link| link.related.link_count } if @category_id == 4
    if @category_id == 5
      return links.sort { |a, b| a.relationship.amount && b.relationship.amount ? b.relationship.amount <=> a.relationship.amount : -1 }
    end

    # TODO sort by date here or do sorting in SQL
    return sorted_current_links(links) + sorted_ended_links(links)
  end

  # input: [ <Link> ] 
  # output: [ [<Link>] [<Link>] ]
  # This groups entities by the 'other' entity so that relationships with the
  # same entity are grouped together
  def group_by_entity(links)
    links.group_by { |l| l.entity2_id }.values
  end

  def sorted_current_links(links)
    links
      .select { |l| l.relationship.end_date.blank? }
      .sort_by { |l| l.relationship.start_date || l.relationship.updated_at.to_s }.reverse
  end

  def sorted_ended_links(links)
    links
      .select { |l| l.relationship.end_date.present? }
      .sort_by { |l| l.relationship.start_date || l.relationship.updated_at.to_s }.reverse
  end
end
