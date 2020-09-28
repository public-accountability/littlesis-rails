# frozen_string_literal: true

class ReferencesController < ApplicationController
  include ReferenceableController
  before_action :authenticate_user!, except: [:entity]
  before_action :set_referenceable, only: [:create]

  ENTITY_DEFAULTS = ActiveSupport::HashWithIndifferentAccess.new(page: 1, per_page: 10).freeze

  def create
    if params[:data][:url].blank?
      return render json: { errors: { url: ["can't be blank"] } }, status: :bad_request
    end

    @referenceable.add_reference(reference_params(:data).to_h)

    if @referenceable.valid?
      # We don't record the history of when references are
      # added, and don't want to confuse the user by having
      # an edit not show up on the modifications page.
      # This is why the system user is being used.
      @referenceable.touch_by(APP_CONFIG['system_user_id'])
      head :created
    else
      render json: { errors: @referenceable.errors }, status: :bad_request
    end
  end

  def destroy
    check_permission 'deleter'
    begin
      Reference.find(params[:id]).destroy!
    rescue ActiveRecord::RecordNotFound
      head :bad_request
    else
      head :ok
    end
  end

  # GET '/references/recent'
  #
  # Required params: entity_ids
  # Optional params: per_page, page, exclude_type
  # Defaults:
  #    per_page: 10
  #    page: 1
  #    exclude_type: fec
  #
  # Takes a list of Entity ids and gathers the most recent
  # refences for those entities and their relationships
  # It also includes the most recent references regardless if they are
  # associated with the entities or not
  # This is used on the add relationship page
  def recent
    per_page = value_for_param(:per_page, 10, :to_i)
    page = value_for_param(:page, 1, :to_i)
    exclude_type = value_for_param(:exclude_type, :fec, :to_sym)
    docs = Reference.last(2).map(&:document) + Document.documents_for_entity(entity: entity_ids, page: page, per_page: per_page, exclude_type: exclude_type)
    render json: docs.uniq.map { |d| d.slice(:id, :name, :url, :publication_date, :excerpt) }
  end

  # Returns recent source links for the given entity
  # required params: 'entity_id'
  # optional params: page, per_page defaults: 1, 10
  def entity
    return head :bad_request unless params[:entity_id]

    @entity = Entity.find(params[:entity_id])
    render json: cached_recent_source_links
  end

  private

  def cached_recent_source_links
    cache_key = "#{@entity.cache_key_with_version}/recent_source_links/#{source_link_params[:page]}/#{source_link_params[:per_page]}"
    Rails.cache.fetch(cache_key, expires_in: 2.weeks) do
      Document
        .documents_for_entity(entity: @entity, page: source_link_params[:page].to_i, per_page: source_link_params[:per_page].to_i, exclude_type: :fec)
        .map { |doc| doc.slice(:name, :url) }
    end
  end

  def source_link_params
    @_source_link_params ||= ENTITY_DEFAULTS.merge(params.permit(:page, :per_page, :entity_id).to_h)
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
