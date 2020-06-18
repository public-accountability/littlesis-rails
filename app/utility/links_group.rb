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
    case @category_id
    when 4
      sort_by_related_link_count(links)
    when 5
      sort_by_amount(links)
    else
      sorted_current_links(links) + sorted_ended_links(links)
    end
  end

  # input: [ <Link> ]
  # output: [ [<Link>] [<Link>] ]
  # This groups entities by the 'other' entity so that relationships with the
  # same entity are grouped together
  def group_by_entity(links)
    links.group_by(&:entity2_id).values
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

  def sort_by_related_link_count(links)
    links.sort_by do |link|
      link.related.link_count
    end
  end

  def sort_by_amount(links)
    links.sort do |a, b|
      if a.relationship.amount && b.relationship.amount
        b.relationship.amount <=> a.relationship.amount
      else
        -1
      end
    end
  end
end
