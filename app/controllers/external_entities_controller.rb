# frozen_string_literal: true

class ExternalEntitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_external_entity, only: %i[show update]

  delegate :external_entity_path, to: 'Rails.application.routes.url_helpers'

  def index
    @matched = params[:matched]&.to_sym || :all
    @dataset = params[:dataset].presence
  end

  # GET /external_entities/:id
  # If the parameter "search" is set, it will display the search tab with that query
  def show
    @entity_matcher = EntityMatcherPresenter.new(
      :model => @external_entity,
      :name => @external_entity.display_information['Name'],
      :search_term => params[:search],
      :primary_ext => @external_entity.primary_ext,
      :match_url => external_entity_path(@external_entity),
      :search_url => external_entity_path(@external_entity),
      :matched? => @external_entity.matched?,
      :active_tab => :matches
    )
  end

  # GET /external_entities/random
  def random
    redirect_to action: :show,
                id: ExternalEntity.random_unmatched(params[:dataset]).id
  end

  # PATCH /external_entities/:id
  # This handles two forms on the matching tool
  # If submitted with the parameter +entity_id+ it will matched with the existing entity.
  # If submitted with the parameter +entity+ with fields name, blurb, and primary_ext,
  # it will create a new entity.
  def update
    if params.key?(:entity_id)
      @external_entity.match_with params.require(:entity_id).to_i
    elsif params.key?(:entity)
      @external_entity.match_with_new_entity(entity_params)
    else
      return head :bad_request
    end

    redirect_to action: 'show'
  end

  private

  def set_external_entity
    @external_entity = ExternalEntity.find(params.fetch(:id)).presenter
  end

  def entity_params
    params.require(:entity).permit(:name, :blurb, :primary_ext).to_h.tap do |h|
      h.store 'last_user_id', current_user.id
      if @external_entity.dataset == 'iapd_advisors'
        h.store 'primary_ext', 'Org'
      elsif @external_entity.dataset == 'nycc'
        h.store 'primary_ext', 'Person'
      end
    end
  end
end
