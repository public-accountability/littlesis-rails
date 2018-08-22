# frozen_string_literal: true

# Graph implementation
#
# edges data structure
# {
#   [entity1, entity2] => relationship_id
# }

require 'matrix'

class Graph
  attr_reader :matrix, :nodes, :edges

  # extend Forwardable
  # def_delegators :@matrix, :[], :row

  def initialize(edges)
    @edges = edges
    @nodes = @edges.keys.flatten.uniq.sort
    nodes_and_indices = @nodes.map.with_index.to_a
    @node_to_index = nodes_and_indices.to_h
    @index_to_node = nodes_and_indices.map(&:reverse).to_h

    @matrix = Matrix.build(@nodes.count) do |row, col|
      edges[[@index_to_node[row], @index_to_node[col]]]
    end
  end

  # Integer --> Set[Integer] (relationship ids)
  def first_degree_relationships(node)
    raise NodeNotInGraphError unless @nodes.include?(node)
  end

  class NodeNotInGraphError < StandardError
  end
end

