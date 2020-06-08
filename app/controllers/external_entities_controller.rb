# frozen_string_literal: true

class ExternalEntitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_external_entity, only: %i[show update]

  def index
    @matched = params[:matched]&.to_sym || :all
    @dataset = params[:dataset].presence
  end

  # GET /external_entities/:id
  # If the parameter "search" is set, it will display the search tab with that query
  def show
    unless @external_entity.matched?
      @search_term = params.fetch(:search, nil)
      @active_tab = @search_term.present? ? :search : :matches
    end
  end

  # GET /external_entities/random
  def random
    redirect_to action: :show,
                id: ExternalEntity.unmatched.order('RAND()').limit(1).pluck(:id).first
  end

  def dataset
  end

  # PATCH /external_entities/:id
  # This does the matching. There are two ways to do this:
  #   submit with the parameter +entity_id+
  #   submit with the parameter +entity+ with name, blurb, and primary_ext
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
      h.store 'primary_ext', 'Org' if @external_entity.dataset == 'iapd_advisors'
    end
  end
end
