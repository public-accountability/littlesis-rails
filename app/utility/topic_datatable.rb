class TopicDatatable
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  attr_reader :topic, :lists, :links, :types, :industries, :list_options

  def initialize(topic, default_list = false)
    @topic = topic
    @lists = default_list ? [topic.default_list] : topic.lists + [topic.default_list]
    @list_hash = Hash[@lists.group_by(&:id).select { |list_id, ary| list_id != topic.default_list_id }.map { |list_id, ary| [list_id, ary.first] }]
    @entity_ids = @lists.map(&:entity_ids).flatten.uniq
    @types = []
    @industries = []
    @list_options = []
    generate_data
  end

  def generate_data
    get_data
    prepare_options
  end

  def data
    generate_data unless @data.present?
    @data
  end

  def get_data
    entities = Entity.includes(:extension_definitions, :os_categories).where(id: @entity_ids, is_deleted: false)

    @data = entities.map do |entity|
      @types = @types.concat(entity.types)
      @industries = @industries.concat(entity.industries)
      entity_data(entity)
    end
  end

  def entity_data(entity)
    lists = @list_hash.select { |list_id, list| list.entities.map(&:id).include?(entity.id) }.values
    {
      id: entity.id,
      list_ids: lists.map(&:id).join(','),
      list_names: lists.map(&:name).sort.join(', '),
      url: entity.legacy_url,
      name: entity.name,
      rels_url: relationships_entity_path(entity),
      blurb: entity.blurb,
      types: entity.types.join(","),
      industries: entity.industries.join(',')
     }
  end

  def prepare_options
    @types.uniq!
    @types = [["Type", ""]].concat(ExtensionDefinition.order(:tier).pluck(:display_name).select { |t| @types.include?(t) }.map { |t| [t, t] })
    @industries -= ["Other", "Unknown", "Non-contribution"]
    @industries.uniq!
    @industries.sort!
    @industries = [["Industry", ""]].concat(@industries)
    @list_options = [["Belongs to List", ""]].concat(@lists.map { |list| [list.name, list.id] }.sort_by(&:first))
  end
end