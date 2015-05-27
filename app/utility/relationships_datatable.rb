class RelationshipsDatatable
  include RelationshipsHelper
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  attr_reader :data, :links, :categories, :types, :industries, :entities, :interlocks

  def initialize(entities, force_interlocks=false)
    @force_interlocks = force_interlocks
    categories = { 0 => ["Relationship", ""] }
    types = []
    industries = []

    @entities = Array(entities)
    entity_ids = @entities.map(&:id)
    @links = Link.includes({ relationship: :position }, :entity, { related: [:extension_definitions, :os_categories] }).where(entity1_id: entity_ids, relationship: { is_deleted: 0 }).where.not(entity2_id: entity_ids).limit(10000)

    if interlocks?
      degree2_links = Link.select(:entity1_id, :entity2_id).where(entity1_id: @links.select { |l| [1,3].include?(l.category_id) }.map(&:entity2_id), category_id: [1, 3]).where.not(entity2_id: entity_ids).map { |l| [l.entity1_id, l.entity2_id] }.uniq
      interlocks = degree2_links.reduce({}) do |hash, link| 
        hash[link[1]] = hash.fetch(link[1], []).push(link[0])
        hash
      end
      top_interlocks = interlocks.select { |k, v| v.count > 1 }.sort { |a, b| a[1].count <=> b[1].count }.reverse.take(10)
      entities = Entity.find(top_interlocks.map { |a| a[0] }).group_by(&:id)
      @interlocks = [["Connected To", ""]].concat(top_interlocks.map { |a| e = entities[a[0]].first; [e.name + " (#{interlocks[e.id].count})", e.id] })
    end

    @data = @links.map do |link|
      rel = link.relationship
      categories[link.category_id] = [rel.category_name, rel.category_name]
      entity = link.entity
      related = link.related
      types = types.concat(related.types)
      industries = industries.concat(related.industries)
      interlock_ids = degree2_links.select { |l| l[0] == related.id }.map { |l| l[1] }.uniq if interlocks?
      { 
        id: link.relationship_id,
        url: rel.legacy_url,
        entity_id: entity.id,
        entity_name: entity.name,
        entity_url: relationships_entity_path(entity),
        related_entity_id: related.id,
        related_entity_name: related.name,
        related_entity_blurb: related.blurb,
        related_entity_blurb_excerpt: excerpt(related.blurb, 50 - related.name.length),
        related_entity_url: relationships_entity_path(related),
        related_entity_types: related.types.join(","),
        related_entity_industries: related.industries.join(','),    
        category: rel.category_name,
        description: rel.description_related_to(entity),
        date: relationship_date(rel),
        is_current: rel.is_current,
        amount: rel.amount,
        updated_at: rel.updated_at,
        is_board: rel.is_board,
        is_executive: rel.is_executive,
        start_date: rel.start_date,
        end_date: rel.end_date,
        interlock_ids: interlocks? ? interlock_ids.join(',') : nil
       }
    end

    @categories = (0..Relationship.all_categories.count-1).map { |n| categories[n] }.select { |a| a.present? }
    types.uniq! 
    @types = [["Entity Type", ""]].concat(ExtensionDefinition.order(:tier).pluck(:display_name).select { |t| types.include?(t) }.map { |t| [t, t] })
    industries -= ["Other", "Unknown", "Non-contribution"]
    industries.uniq!
    industries.sort!
    @industries = [["Entity Industry", ""]].concat(industries)
  end

  def relationships
    @links.collect(&:relationship).uniq { |r| r.id }
  end

  def list?
    @entities.count > 1
  end

  def interlocks?
    @num_links ||= @links.count
    @force_interlocks or @num_links < 1000
  end
end