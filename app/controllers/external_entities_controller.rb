# frozen_string_literal: true

class ExternalEntitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_external_entity, only: %i[show update search]

  # GET /external_entities/:id
  # if paramter "search" is set, it will display the search tab with that query
  def show
    if @external_entity.matched?
      render 'already_matched'
    else
      @search_term = params.fetch(:search, nil)
      @active_tab = @search_term.present? ? :search : :matches
      render 'show'
    end
  end

  # GET /external_entities/random
  def random
    redirect_to action: :show,
                id: ExternalEntity.unmatched.order('RAND()').limit(1).pluck(:id).first
  end

  # PATCH /external_entities/:id
  def update
    @external_entity.match_with params.require(:entity_id).to_i
    redirect_to action: 'show'
  end

  private

  def set_external_entity
    @external_entity = ExternalEntity.find(params.fetch(:id)).presenter
  end
end
