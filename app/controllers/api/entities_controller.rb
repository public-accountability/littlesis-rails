class Api::EntitiesController < Api::ApiController
  ENTITY_SEARCH_PER_PAGE = 10
  before_action :set_entity, except: [:search]
  before_action :set_options, except: [:search]

  def show
    render json: ApiUtils::Response.new(@entity, @options)
  end

  def relationships
  end

  def extensions
    records = ExtensionRecord.includes(:extension_definition).where(entity_id: @entity.id)
    render json: ApiUtils::Response.new(records)
  end

  def search
    return head :bad_request unless params[:q].present?
    entities = Entity::Search.search(params[:q]).per(ENTITY_SEARCH_PER_PAGE).page(page_requested)
    
    render json: { place: 'holder' }
  end

  private

  def page_requested
    return 1 if params[:page].blank? || params[:page].to_i.zero?
    params[:page].to_i
  end
    

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
