# frozen_string_literal: true

class Api::EntitiesController < Api::ApiController
  ENTITY_SEARCH_PER_PAGE = 10
  VALID_CATEGORY_IDS = (1..12).to_set.freeze

  before_action :set_entity, except: [:search]
  before_action :set_options, except: [:search]

  def show
    render json: @entity.as_api_json(@options)
  end

  def relationships
    relationships = @entity
                      .relationships
                      .where(category_id_query)
                      .reorder(updated_at: :desc)
                      .page(page_requested)
                      .per(PER_PAGE)
    render json: Api.as_api_json(relationships)
  end

  def lists
    render json: Api.as_api_json(@entity.lists.where("ls_list.access <> #{Permissions::ACCESS_PRIVATE}"))
  end

  def extensions
    render json: Api.as_api_json(@entity.extension_records.includes(:extension_definition))
  end

  def search
    return head :bad_request if params[:q].blank?

    entities = Entity::Search.search(params[:q], search_options).per(ENTITY_SEARCH_PER_PAGE).page(page_requested)
    render json: Api.as_api_json(entities)
  end

  def connections
    query = EntityConnectionsQuery.new(@entity)
    query.page = page_requested
    query.category_id = params[:category_id]
    query.per_page = params[:per_page] || 15
    query.order = :link_count # expose this to the API?
    render json: Api.as_api_json(query.run)
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

  def search_options
    {}.tap do |h|
      h[:tags] = params[:tags] if params[:tags]
      h[:regions] = Array.wrap(params[:region]) if params[:region]
      h[:regions] = params[:regions] if params[:regions]
    end
  end

  def category_id_query
    return nil if params['category_id'].blank?

    category_id = params['category_id'].to_i
    if VALID_CATEGORY_IDS.include?(category_id)
      { category_id: category_id }
    else
      raise Exceptions::InvalidRelationshipCategoryError
    end
  end
end
