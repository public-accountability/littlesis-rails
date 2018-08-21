# frozen_string_literal: true

class RelationshipsDatatable
  include RelationshipsHelper
  include ApplicationHelper
  include Rails.application.routes.url_helpers
  include Routes

  attr_reader :data, :links, :categories, :types, :industries, :entities, :interlocks, :lists

  def initialize(entities, force_interlocks = false)
    @force_interlocks = force_interlocks
    categories = { 0 => ["Relationship", ""] }
    types = []
    industries = []

    @entities = Array.wrap(entities)
    @entity_ids = @entities.map(&:id)
    @links = load_links
    @related_ids = @links.map(&:entity2_id).uniq

    if interlocks?
      degree2_links = Link.select(:entity1_id, :entity2_id).where(entity1_id: @links.select { |l| [1,3].include?(l.category_id) }.map(&:entity2_id), category_id: [1, 3]).where.not(entity2_id: @entity_ids).map { |l| [l.entity1_id, l.entity2_id] }.uniq
      interlocks = degree2_links.reduce({}) do |hash, link| 
        hash[link[1]] = hash.fetch(link[1], []).push(link[0])
        hash
      end
      top_interlocks = interlocks.select { |k, v| v.count > 1 }.sort { |a, b| a[1].count <=> b[1].count }.reverse.take(10)
      entities = Entity.find(top_interlocks.map(&:first)).group_by(&:id)
      @interlocks = [["Connected To", ""]].concat(top_interlocks.map { |a| e = entities[a[0]].first; [e.name + " (#{interlocks[e.id].count})", e.id] })
    end

    if lists?
      list_entities = ListEntity.select(:list_id, :entity_id).includes(:list).where(entity_id: @related_ids).where(ls_list: { is_admin: false }).map { |le| [le.list_id, le.entity_id] }.uniq
      list_hash = list_entities.reduce({}) do |hash, item|
        hash[item[0]] = hash.fetch(item[0], []).push(item[1])
        hash
      end
      top_lists = list_hash.select { |k, v| v.count > 1 }.sort { |a, b| a[1].count <=> b[1].count }.reverse.take(10)
      lists = List.find(top_lists.map(&:first)).group_by(&:id)
      @lists = [["On List", ""]].concat(top_lists.map { |a| l = lists[a[0]].first; [l.name + " (#{list_hash[l.id].count})", l.id] })
    end

    @data = @links.map do |link|
      rel = link.relationship
      categories[link.category_id] = [rel.category_name, rel.category_name]
      entity = link.entity
      related = link.related
      types = types.concat(related.types)
      industries = industries.concat(related.industries)
      interlock_ids = degree2_links.select { |l| l[0] == related.id }.map { |l| l[1] }.uniq if interlocks?
      list_ids = list_hash.to_a.select { |l| l[1].include?(related.id) }.map { |l| l[0] }.uniq if lists?
      { 
        id: link.relationship_id,
        url: relationship_path(rel),
        entity_id: entity.id,
        entity_name: entity.name,
        entity_url: datatable_entity_path(entity),
        related_entity_id: related.id,
        related_entity_name: related.name,
        related_entity_blurb: related.blurb,
        related_entity_blurb_excerpt: excerpt(related.blurb, 50 - related.name.length),
        related_entity_url: datatable_entity_path(related),
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
        interlock_ids: interlocks? ? interlock_ids.join(',') : nil,
        list_ids: lists? ? list_ids.join(',') : nil
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

  def lists?
    @related_ids.count < 1000
  end

  def interlocks?
    @num_links ||= @links.count
    @force_interlocks or @num_links < 1000
  end

  private

  # NOTE: a previous version of this query included
  # an addition where that prohibited relationships
  # that were to yourself:  ` where.not(entity2_id: @entity_ids) `
  def load_links
    Link
      .includes(:entity, relationship: :position, related: [:extension_definitions, :os_categories])
      .where(entity1_id: @entity_ids)
      .limit(5_000)
  end
end
