# frozen_string_literal: true

# Graph Implementation for Relationships/links

class RelationshipsGraph
  attr_reader :edges, :nodes

  # Relationships is a Array of Hash with these required keys:
  #    id, entity1_id, entity2_id, category_id
  # Other fields will be ignored
  #
  # @edges is a hash from maps id to the other values of the relationship:
  #   { 123 => { 'entity1_id' => 1, 'entity2_id' => 2, 'category_id' => 3 } }
  #
  # @nodes is a hash mapping entity to two sets with node ids and associated nodes
  #    { 1000 => { ids: Set[10,20,30], associated: Set[5,200,42] }
  #
  def initialize(relationships)
    @edges = {}
    @nodes = {}

    relationships.each do |r|
      @edges.store r['id'], r.slice('entity1_id', 'entity2_id', 'category_id')

      r.values_at('entity1_id', 'entity2_id').each do |entity|
        @nodes[entity] = default_node_value if @nodes[entity].nil?
      end

      entity1, entity2, id = r.values_at('entity1_id', 'entity2_id', 'id')

      @nodes[entity1][:associated].add(entity2)
      @nodes[entity2][:associated].add(entity1)
      @nodes[entity1][:ids].add(id)
      @nodes[entity2][:ids].add(id)
    end

    @edges.freeze
    @nodes.freeze
  end

  # Searches through the graph by levels.
  # Returns an array of sets of connected nodes by level.
  #
  #  max_depth -- the maximum number of levels to searchg
  #
  #  input: Integer | Set[Integer] | Array[Integer]
  #  output: Array[Set]
  def connected_nodes(root_nodes, max_depth: 1, visited_nodes: Set.new, levels: [])
    # accept single values or anything that responds to #to_a
    queue = wrap(root_nodes)
    visited_nodes.merge(queue.to_set)
    nodes_found_this_round = Set.new

    until queue.empty?
      new_nodes = @nodes.fetch(queue.pop)[:associated].difference(visited_nodes)
      nodes_found_this_round.merge(new_nodes)
      visited_nodes.merge(new_nodes)
    end

    levels << nodes_found_this_round

    return levels if search_is_over?(levels, max_depth)

    connected_nodes(nodes_found_this_round,
                    max_depth: max_depth,
                    visited_nodes: visited_nodes,
                    levels: levels)
  end

  # Searches through the graph by levels.
  # Returns an array of sets of connected node ids by level.
  #
  # Similar to connected_nodes except it returns the id of the node instead of the
  # entities that are connected
  def connected_ids(root_nodes = nil, max_depth: 1, visited_ids: Set.new, levels: [])
    raise ArgumentError, 'Root nodes not provided' if levels.length.zero? && root_nodes.nil?

    if root_nodes
      ids_found_this_round = wrap(root_nodes)
                               .map { |n| @nodes[n][:ids] }
                               .reduce(:+)
    else
      last_round_nodes = levels
                           .last
                           .map { |id| @edges[id].values_at('entity1_id', 'entity2_id') }
                           .flatten
                           .uniq

      ids_found_this_round = last_round_nodes
                               .map { |n| @nodes[n][:ids] }
                               .reduce(:+)
                               .difference(visited_ids)
    end

    levels << ids_found_this_round
    return levels if search_is_over?(levels, max_depth)

    visited_ids.merge(ids_found_this_round)
    connected_ids(max_depth: max_depth, visited_ids: visited_ids, levels: levels)
  end

  private

  def search_is_over?(levels, max_depth)
    levels.size == max_depth || levels.last.empty?
  end

  def wrap(x)
    x.respond_to?(:to_a) ? x.to_a : Array.wrap(x)
  end

  def default_node_value
    { ids: Set.new, associated: Set.new }
  end

  # EXCEPTIONS
end
