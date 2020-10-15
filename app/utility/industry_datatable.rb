class IndustryDatatable
  include Rails.application.routes.url_helpers

  attr_reader :industry, :types, :industries

  def initialize(industry, force_interlocks=false)
    @industry = industry
    @category_ids = OsCategory.where(industry_id: @industry.industry_id).pluck(:category_id)
    @entity_ids = OsEntityCategory.where(category_id: @category_ids).pluck(:entity_id)
    @types = []
    @industries = []
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
    entities = Entity.includes(:extension_definitions, :os_categories).where(id: @entity_ids)

    @data = entities.map do |entity|
      @types = @types.concat(entity.types)
      @industries = @industries.concat(entity.industries)
      entity_data(entity)
    end
  end

  def entity_data(entity)
    {
      id: entity.id,
      url: entity.url,
      name: entity.name,
      rels_url: concretize_datatable_entity_path(entity),
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
    @industries = [["Other Industry", ""]].concat(@industries)
  end
end
