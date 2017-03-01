class Api::EntitiesController < Api::ApiController
  before_action :set_entity

  def show
    render json: ApiUtils::Response.new(@entity)
  end

  def relationships
  end

  def details
  end

  private

  def set_entity
    @entity = Entity.unscoped.find(params[:id])
    raise Entity::EntityDeleted if @entity.is_deleted?
  end
end
