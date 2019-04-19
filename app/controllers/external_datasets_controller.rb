# frozen_string_literal: true

class ExternalDatasetsController < ApplicationController
  before_action :load_row, only: %i[row matches]

  def index
  end

  def iapd
  end

  # get /external_datasets/row/:id
  def row
    render json: @row
  end

  # get /external_datasets/row/:id/matches
  def matches
    render json: @row.matches
  end

  # post /external_datasets/row/:id/match
  # { "entity_id": 123121 }
  def match
  end

  private

  def load_row
    @row = ExternalDataset.find(params[:id])
  end
end
