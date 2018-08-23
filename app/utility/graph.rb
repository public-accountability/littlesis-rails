# frozen_string_literal: true

# Graph implementation
#
# edges data structure:
#
# [ [ entity1, entity2, data ] ]
#
# Data is optional and can be any object.
# If present a lookup table is created with this data structure:
#  {
#     [entity1, entity2] => data
#  }

class Graph
  attr_reader :edges, :graph, :lookup

  def initialize(edges)
    @edges = edges
    @graph = {}
    @graph.default_proc = proc { Set.new }

    if (create_lookup = !@edges.first[2].nil?)
      @lookup = {}
    else
      @lookup = nil
    end

    @edges.each do |(entity1, entity2, data)|
      @graph[entity1] = @graph[entity1].add(entity2)
      @graph[entity2] = @graph[entity2].add(entity1)
      @lookup.store [entity1, entity2], data if create_lookup
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
