# frozen_string_literal: true

class Api::EntitiesController < Api::ApiController
  ENTITY_SEARCH_PER_PAGE = 10
  VALID_CATEGORY_IDS = (1..12).to_set.freeze
  BATCH_LIMIT = 300

  before_action :set_entity, except: [:search, :batch]
  before_action :set_options, only: [:search]

  # /api/entities/:id
  def show
    render json: @entity.as_api_json(**@options)
  end

  # /api/entities?ids="10,11,12"
  def batch
    ids = params.require(:ids).split(',').map(&:to_i)

    raise Exceptions::PermissionError if ids.length > BATCH_LIMIT

    render json: Api.as_api_json(Entity.where(id: ids))
  end

  # /api/entities/:id/relationships
  def relationships
    relationships = @entity
                      .relationships
                      .where(category_id_query)
                      .reorder(relationships_order)
                      .page(page_requested)
                      .per(per_page)

    render json: Api.as_api_json(relationships)
  end

  # /api/entities/:id/lists
  def lists
    render json: Api.as_api_json(@entity.lists.where("ls_list.access <> #{Permissions::ACCESS_PRIVATE}"))
  end

  # /api/entities/:id/extensions
  def extensions
    render json: Api.as_api_json(@entity.extension_records.includes(:extension_definition))
  end

  def search
    return head :bad_request if params[:q].blank?

    entities = Entity::Search.search(params[:q], search_options).per(ENTITY_SEARCH_PER_PAGE).page(page_requested)
    render json: Api.as_api_json(entities)
  end

  # /api/entities/:id/connections
  def connections
    query = EntityConnectionsQuery.new(@entity)
    query.page = page_requested
    query.category_id = params[:category_id]
    query.per_page = params[:per_page] || 15
    query.order = :link_count # expose this to the API?
    render json: Api.as_api_json(query.run)
  end

  private

  # @return [Integer]
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

  # @return [Hash, String] sort conditions based on params[:sort]
  def relationships_order
    case params[:sort]
    when 'amount'
      "amount DESC NULLS LAST"
    when 'oldest'
      { created_at: :asc }
    else # default = 'recent'
      { updated_at: :desc }
    end
  end

  def per_page
    params[:per_page]&.to_i || PER_PAGE
  end
end
