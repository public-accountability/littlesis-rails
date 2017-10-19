class ReferencesController < ApplicationController
  include ReferenceableController
  before_filter :authenticate_user!, except: [:entity]
  before_action :set_referenceable, only: [:create]

  ENTITY_DEFAULTS = { page: 1, per_page: 10 }.freeze

  def create
    if params[:data][:url].blank?
      return render json: { errors: { url: ["can't be blank"] } }, status: :bad_request
    end
    @referenceable.add_reference(reference_params(:data))

    if @referenceable.valid?
      @referenceable.update(last_user_id: current_user.sf_guard_user_id)
      head :created
    else
      render json: { errors: @referenceable.errors }, status: :bad_request
    end
  end

  def destroy
    check_permission "deleter"
    begin
      Reference.find(params[:id]).destroy!
    rescue ActiveRecord::RecordNotFound
      head :bad_request
    else
      head :ok
    end
  end

  # Takes a list of Entity ids and gathers the most recent
  # refences for those entities and their relationships
  # It also includes the most recent references regardless if they are
  # associated with the entities or not
  # This is used on the add relationship page
  # JSON result:  [ { id:, name:, url: } ]
  def recent
    docs = Reference.last(2).map(&:document) + Document.documents_for_entity(entity: entity_ids, page: 1, per_page: 10)
    render json: docs.uniq.map { |d| d.slice(:id, :name, :url) }
  end

  # Returns recent source links for the given entity
  # required params: 'entity_id'
  # optional params: page, per_page defaults: 1, 10
  def entity
    return head :bad_request unless params[:entity_id]
    params.replace(ENTITY_DEFAULTS.merge(params))
    @entity = Entity.find(params[:entity_id])
    render json: cached_recent_source_links
  end

  private

  def cached_recent_source_links
    Rails.cache.fetch("#{@entity.alt_cache_key}/recent_source_links/#{params[:page]}/#{params[:per_page]}", expires_in: 2.weeks) do
      Document
        .documents_for_entity(entity: @entity, page: params[:page].to_i, per_page: params[:per_page].to_i, exclude_type: :fec)
        .map { |doc| doc.slice(:name, :url) }
    end
  end

  def set_referenceable
    @referenceable = params[:data][:referenceable_type].constantize.find(params[:data][:referenceable_id].to_i)
  end

  def entity_ids
    if params[:entity_ids].is_a?(String)
      params[:entity_ids].split(",").map(&:to_i).uniq
    else
      params[:entity_ids].map(&:to_i).uniq
    end
  end
end
