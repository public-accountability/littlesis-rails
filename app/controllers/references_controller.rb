# frozen_string_literal: true

class ReferencesController < ApplicationController
  include ReferenceableController
  before_action :authenticate_user!, except: [:entity, :documents]
  before_action :current_user_can_edit?, except: [:entity, :documents]
  before_action :set_referenceable, only: [:create, :documents]

  def create
    @referenceable.add_reference(reference_params(:data).to_h)

    if @referenceable.valid?
      # We don't record the history of when references are
      # added, and don't want to confuse the user by having
      # an edit not show up on the modifications page.
      # This is why the system user is being used.
      @referenceable.touch_by(Rails.application.config.littlesis.fetch(:system_user_id))

      respond_to do |format|
        format.html { redirect_back(fallback_location: after_create_reference_fallback_location) }
        format.json { head :created }
      end
    else
      respond_to do |format|
        format.html do
          format.html { redirect_back(fallback_location: after_create_reference_fallback_location) }
          format.json { render json: { errors: @referenceable.errors }, status: :bad_request }
        end
      end
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

  # /references/documents
  # returns all documents for referenceable
  def documents
    render json: @referenceable.documents.map do |d|
      d.attributes.slice('id', 'name', 'updated_at', 'created_at').merge!(url: d.url)
    end
  end

  # GET '/references/recent'
  # Used by reference selector
  # Required params: entity_ids
  # Optional params: per_page, page,
  # Defaults:
  #    per_page: 10
  #    page: 1
  def recent
    render json: RecentEntityReferencesQuery
             .run(entity_ids,
                  page: value_for_param(:page, 1, :to_i),
                  per_page: value_for_param(:per_page, 10, :to_i))
             .map { |d| d.slice(:id, :name, :url, :publication_date, :excerpt) }
  end

  # GET /references/enity
  # Returns recent source links for the given entity
  # Used by source links sidebar
  # required params: 'entity_id'
  # optional params: page, per_page defaults: 1, 10
  def entity
    return head :bad_request unless params[:entity_id]

    render json: RecentEntityReferencesQuery
             .run(params[:entity_id].to_i,
                  page: value_for_param(:page, 1, :to_i),
                  per_page: value_for_param(:per_page, 10, :to_i))
             .map { |doc| doc.slice(:name, :url) }
  end

  private

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

  def after_create_reference_fallback_location
    case @referenceable
    when Entity
      references_entity_path(@referenceable)
    else
      home_dashboard_path
    end
  end
end
