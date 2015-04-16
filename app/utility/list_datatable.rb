class ListDatatable
  include RelationshipsHelper
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  attr_reader :list, :data, :links, :types, :industries, :entities, :interlocks

  def initialize(list, force_interlocks=false)
    @list = list
    @force_interlocks = force_interlocks
    @num_interlocks = 20
    categories = { 0 => ["Category", ""] }
    types = []
    industries = []

    entity_ids = @list.entities.map(&:id)
    @links = Link.includes({ relationship: :position }, :entity).where(entity1_id: entity_ids, category_id: [1, 3], relationship: { is_deleted: 0 }).where.not(entity2_id: entity_ids).limit(10000)
    @num_links = @links.count

    if interlocks?
      interlocks = @links.reduce({}) do |hash, link| 
        hash[link.entity2_id] = hash.fetch(link.entity2_id, []).push(link.entity1_id).uniq
        hash
      end
      top_interlocks = interlocks.select { |k, v| v.count > 1 }.sort { |a, b| a[1].count <=> b[1].count }.reverse.take(@num_interlocks)
      entities = Entity.where(id: top_interlocks.map { |a| a[0] }).group_by(&:id)
      @interlocks = [["Interlocks", ""]].concat(top_interlocks.map { |a| e = entities[a[0]].first; [e.name + " (#{interlocks[e.id].count})", e.id] })
    end

    list_entities = ListEntity.includes(entity: [:extension_definitions, :os_categories]).where(list_id: @list.id, is_deleted: false, entity: { is_deleted: false })
    @data = list_entities.map do |le|
      entity = le.entity
      types = types.concat(entity.types)
      industries = industries.concat(entity.industries)
      interlock_ids = top_interlocks.select { |l| l[1].include?(entity.id) }.map { |l| l[0] }.uniq if interlocks?
      {
        rank: le.rank,
        id: entity.id,
        url: entity.legacy_url,
        name: entity.name,
        rels_url: relationships_entity_path(entity),
        blurb: entity.blurb,
        types: entity.types.join(","),
        industries: entity.industries.join(','),    
        interlock_ids: interlocks? ? interlock_ids.join(',') : nil
       }
    end

    @categories = (0..11).map { |n| categories[n] }.select { |a| a.present? }
    types.uniq!
    @types = [["Entity Type", ""]].concat(ExtensionDefinition.order(:tier).pluck(:display_name).select { |t| types.include?(t) }.map { |t| [t, t] })
    industries -= ["Other", "Unknown", "Non-contribution"]
    industries.uniq!
    industries.sort!
    @industries = [["Industry", ""]].concat(industries)
  end

  def ranked?
    @list.is_ranked
  end

  def interlocks?
    @force_interlocks or (@num_links < 5000)
  end
end