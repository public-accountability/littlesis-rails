module Graph

  def build links
    write_to_file(parse_nodes(links))
  end

  def write_to_file(adj_list)
    open("data/graph.json", "wb") do |file|
      file << JSON.dump(adj_list)
    end
  end

  # def parse_nodes(links)
  #   links.group_by { |l| l.entity1_id }.map { |id,ls| format_node id, ls }
  # end

  # def format_node id, links
  #   {
  #     node1: id,
  #     adj: parse_edges(links)
  #   }
  # end

  # def parse_edges links
  #   links.group_by { |l| l.entity2_id }.map{ |id, ls| format_edges(id, ls) }
  # end

  # def format_edges(id, links)
  #   {
  #     node2: id,
  #     edge_labels: links.map{ |l| pick_edge_labels(l) }
  #   }
  # end
  def parse_nodes links
    links.reduce({}) do |acc, link|
      id1 = link.entity1_id
      acc[id1] = parse_edges(acc,id1,link)
      acc
    end
  end

  def parse_edges acc, id1, link
    id2 = link.entity2_id
    acc_ = acc.fetch(id1,{})
    acc_[id2] = acc_.fetch(id2,[]).concat(pick_edge_labels(link))
    acc_
  end


  def pick_edge_labels(link)
    hash = link.relationship.attributes.merge(link.attributes)
    entity_order = hash[:is_reverse] ? 2 : 1
    related_order = 2 - entity_order
    [{
      relationship_id: hash["relationship_id"],
      category_id: hash["category_id"],
      start_date: hash["start_date"],
      end_date: hash["end_date"],
      is_current: hash["is_current"],
      entity_description: hash["description#{entity_order}"],
      related_description: hash["description#{related_order}"]
    }]
  end
end
