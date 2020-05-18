# frozen_string_literal: true

class ExternalEntitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_external_entity, only: %i[show update]

  # GET /external_entities/:id
  def show
    if @external_entity.matched?
      render 'already_matched'
    end
  end

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
