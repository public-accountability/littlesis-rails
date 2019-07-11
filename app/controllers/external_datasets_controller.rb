# frozen_string_literal: true

class ExternalDatasetsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_or_create_entity, only: %i[match]
  before_action :load_row, only: %i[row matches match]

  rescue_from Exceptions::InvalidEntityIdError do
    render json: { error: 'Entity id is invalid' }, status: :bad_request
  end

  def index
  end

  # example url:
  #   match iapd advisors with starting id: GET /external_datasets/iapd?flow=advisors&start=123
  #   match iapd owners: GET /external_datasets/iapd?flow=owners
  #   load owners queue for advisor: GET /external_datasets/iapd?flow=queue&id=789
  def iapd
    @flow = params.fetch(:flow, 'advisors')

    if @flow == 'queue'
      advisor_queue = IapdQueueService.new(params[:id])
      @queue = advisor_queue.queue
      @queue_meta = advisor_queue.queue_meta
    end
    @start = params[:start]&.to_i
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
    results = @row.match_with(@entity).map(&:result)

    if @row.matched?
      successful_res = { status: 'matched', results: results, entity: @entity.to_hash }
      render json: successful_res, status: :ok
    else
      render json: { status: 'error', error: "Failed to save match for row #{@row.id}" },
             status: :internal_server_error
    end
  rescue ExternalDataset::RowAlreadyMatched
    render json: { status: 'error', error: "Row #{@row.id} is already matched" }, status: :conflict
  end

  # GET /external_datasets/:dataset/flow/:flow/next
  # { "next": id }
  def flow
    id = ExternalDataset
           .dataset_to_model(params[:dataset])
           .next(params[:flow])&.id

    render json: { 'next' => id }
  end

  # GET/POST /external_datasets/:dataset/search
  def search
    return head :not_found unless params[:dataset] == 'iapd'

    if request.post?
      render json: IapdDatum.search(params.require(:q), type: :advisor).to_a
    end
  end

  private

  def find_or_create_entity
    if params_contain_entity_id?
      @entity = Entity.find(params.require(:entity_id))
    else
      @entity = Entity.create!(
        params.require(:entity).permit(:name, :primary_ext, :blurb).to_h
      )
    end
  end

  def params_contain_entity_id?
    return false unless params[:entity_id]

    if /\A[0-9]+\Z/.match?(params.require(:entity_id).to_s)
      true
    else
      raise Exceptions::InvalidEntityIdError
    end
  end

  def load_row
    @row = ExternalDataset.find(params[:id])
  end
end
