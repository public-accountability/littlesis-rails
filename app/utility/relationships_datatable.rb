# frozen_string_literal: true

# {
#   root: [ entity_ids ],
#   categories: [],
#   types: [],
#   interlocks: []
#   relationships: []
#   entities: { 123 => Entity Hash }
# }

class RelationshipsDatatable
  INTERLOCKS_TAKE = 15

  attr_reader :root_entities,
              :root_entity_ids,
              :entities,
              :relationships,
              :links,
              :related_ids,
              :rgraph,
              :interlocks

  def initialize(entities)
    @root_entities = Array.wrap(entities).map { |e| Entity.entity_for(e) }
    @root_entity_ids = @root_entities.map(&:id)
    @links = load_links
    @related_ids = @links.map(&:entity2_id).uniq
    @entities = load_entities
    @rgraph = RelationshipsGraph.new_from_entity(@root_entity_ids)
    @interlocks = load_interlocks
    @interlocks_entity_ids = @interlocks.pluck('id').to_set
    @relationships = load_relationships
  end

  def data
    { 'root' => @root_entity_ids,
      'entities' => @entities,
      'types' => types,
      'categories' => categories,
      'relationships' => @relationships,
      'interlocks' => @interlocks }
  end

  private

  # ---> [{}]
  def load_relationships
    @links.map do |link|
      interlocked_entities = interlocked_entities_for(link.entity2_id)
      RelationshipDatatablePresenter.new(link.relationship, 'interlocks' => interlocked_entities).to_h
    end
  end

  # --> {}
  def load_entities
    @links
      .flat_map { |l| [l.entity, l.related] }
      .uniq
      .each_with_object({}) { |e, h| h.store(e.id, EntityDatatablePresenter.new(e).to_hash) }
  end

  def types
    @entities.values.flat_map { |e| e['types'] }.uniq.sort
  end

  def categories
    @relationships.map { |r| r['category_id'] }.uniq.sort
  end

  def load_interlocks
    interlocked_entities = @rgraph.sorted_interlocks(@root_entity_ids).take(INTERLOCKS_TAKE)
    entity_lookup = Entity.lookup_table_for(interlocked_entities.map(&:id))

    interlocked_entities.map do |e|
      entity_lookup
        .fetch(e.id)
        .attributes
        .slice('id', 'name')
        .merge('interlocks_count' => e.count)
    end
  end

  def interlocked_entities_for(entity_id)
    interlocked_entities = @rgraph.nodes.dig(entity_id, :associated)&.intersection(@interlocks_entity_ids)&.to_a
    if interlocked_entities.nil?
      []
    else
      interlocked_entities
    end
  end

  # a previous version of this query prohibited self-relationships: `where.not(entity2_id: @entity_ids)`
  def load_links
    Link
      .includes(:entity, relationship: :position, related: [:extension_definitions])
      .where(entity1_id: @root_entity_ids)
    # .limit(10_000)
  end
end
