namespace :graph do
  desc "builds adjacency list of complete relaitionship graph"
  task :build_all => [:environment] do |task|
    def link_fields(hash)
      entity_order = hash[:is_reverse] ? 2 : 1
      related_order = 2 - entity_order

      {
        relationship_id: hash["relationship_id"],
        category_id: hash["category_id"],
        start_date: hash["start_date"],
        end_date: hash["end_date"],
        is_current: hash["is_current"],
        entity_description: hash["description#{entity_order}"],
        related_description: hash["description#{related_order}"]

      }
    end

    hash = Link.includes(:relationship).reduce({}) do |hash, link|
      hash[link.entity1_id] = hash.fetch(link.entity1_id, []).concat([link])
      hash
    end

    my_hash = hash.map do |entity_id, links| 
      { 
        node: entity_id, 
        adj: links.map do |link| 
          { 
            node: link.entity2_id, 
            edge: link_fields(link.relationship.attributes.merge(link.attributes)) 
          }
        end
      }
    end

    open("data/graph.json", "wb") do |file|
      file << JSON.dump(my_hash)
    end
  end
end
