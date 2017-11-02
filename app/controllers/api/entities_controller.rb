class Api::EntitiesController < Api::ApiController
  ENTITY_SEARCH_PER_PAGE = 10
  before_action :set_entity, except: [:search]
  before_action :set_options, except: [:search]

  def show
    render json: @entity.as_api_json(@options) #ApiUtils::Response.new(@entity, @options)
  end

  def relationships
    relationships = @entity.relationships.order(updated_at: :desc).page(page_requested).per(PER_PAGE)
    render json: Api.as_api_json(relationships)
  end

  def lists
    render json: Api.as_api_json(@entity.lists.where("ls_list.access <> #{Permissions::ACCESS_PRIVATE}"))
  end

  def extensions
    render json: Api.as_api_json(@entity.extension_records.includes(:extension_definition))
  end

  def search
    return head :bad_request unless params[:q].present?
    entities = Entity::Search.search(params[:q]).per(ENTITY_SEARCH_PER_PAGE).page(page_requested)
    render json: Api.as_api_json(entities)
  end

  private

  def page_requested
    return 1 if params[:page].blank? || params[:page].to_i.zero?
    params[:page].to_i
  end

  def set_options
    @options = {}
    @options.merge!(exclude: :extensions) unless param_to_bool(params[:details])
  end

  def set_entity
    @entity = Entity.unscoped.find(params[:id])
    raise Entity::EntityDeleted if @entity.is_deleted?
  end
end
