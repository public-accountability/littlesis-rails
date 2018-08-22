# frozen_string_literal: true

# Graph implementation
#
# edges data structure
# {
#   [entity1, entity2] => relationship_id
# }

class Graph

  def initialize(edges)
    @edges = edges
    @graph = {}
    @graph.default_proc = proc { Set.new }

    edges.each do |entity_ids, _|
      @graph[entity_ids.first] = @graph[entity_ids.first].add(entity_ids.last)
      @graph[entity_ids.last] = @graph[entity_ids.last].add(entity_ids.first)
    end

    @graph.default_proc = nil
  end

  def connected_nodes(nodes, max_depth: 1, visited_nodes: Set.new, levels: [])
    queue = nodes.respond_to?(:to_a) ? nodes.to_a : Array.wrap(nodes)
    visited_nodes.merge(queue.to_set)
    nodes_found_this_round = Set.new

    until queue.empty?
      nodes = @graph.fetch(queue.pop)
      new_nodes = nodes.difference(visited_nodes)
      nodes_found_this_round.merge(new_nodes)
      visited_nodes.merge(new_nodes)
    end

    levels << nodes_found_this_round

    if levels.size == max_depth || nodes_found_this_round.empty?
      return levels
    else
      return connected_nodes(nodes_found_this_round,
                             max_depth: max_depth,
                             visited_nodes: visited_nodes,
                             levels: levels)
    end
  end
end

