# frozen_string_literal: true

class ExternalEntitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_external_entity

  # GET /external_entities/:id
  def show
    if @external_entity.matched?
      render 'already_matched'
    end
  end

  # PATCH /external_entities/:id
  def update
  end

  private

  def set_external_entity
    @external_entity = ExternalEntity.find(params.fetch(:id))
  end
end
