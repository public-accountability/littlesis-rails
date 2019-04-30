# frozen_string_literal: true

class ExternalDatasetsController < ApplicationController
  before_action :set_entity_id, only: %i[match]
  before_action :load_row, only: %i[row matches match]

  def index
  end

  def iapd
    @flow = params.fetch(:flow, 'advisors')
    @start = '1'
    # @start = params.fetch(:start, IapdDatum.next_id(@flow)).to_sym
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
    # if @row.match_with(@entity_id)
    # else
    # end
  end

  # GET /external_datasets/:dataset/flow/:flow/next
  # { "next": id }
  def flow
    
  end

  private

  def set_entity_id
    if /\A[0-9]+\Z/.match?(params.require(:entity_id))
      @entity_id = params.require(:entity_id).to_i
    else
      render json: { error: 'Entity id is not a number' }, status: :bad_request
    end
  end

  def load_row
    @row = ExternalDataset.find(params[:id])
  end
end
