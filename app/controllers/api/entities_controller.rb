class Api::EntitiesController < Api::ApiController
  before_action :set_entity, :set_options

  def show
    render json: ApiUtils::Response.new(@entity, @options)
  end

  def relationships
  end

  def extensions
    records = ExtensionRecord.includes(:extension_definition).where(entity_id: @entity.id)
    render json: ApiUtils::Response.new(records)
  end

  private

  def set_options
    @options = {
      include_entity_details: param_to_bool(params[:details])
    }
  end

  def set_entity
    @entity = Entity.unscoped.find(params[:id])
    raise Entity::EntityDeleted if @entity.is_deleted?
  end
end
