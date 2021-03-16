# frozen_string_literal: true

module DeletionRequests
  class EntitiesController < DeletionRequests::BaseController
    before_action :set_entity

    def create
      @deletion_request = DeletionRequest.create!(deletion_request_params)
      super
    end

    private

    def deletion_request_params
      {
        user: current_user,
        entity: @entity,
        justification: params.require('justification')
      }
    end

    def set_deletion_request
      @deletion_request = DeletionRequest.find(params.require(:id).to_i)
    end

    def set_entity
      @entity = @deletion_request&.entity || Entity.find(params.require(:entity_id))
    end
  end
end
