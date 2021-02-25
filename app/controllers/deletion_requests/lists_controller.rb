# frozen_string_literal: true

module DeletionRequests
  class ListsController < DeletionRequests::BaseController
    before_action :set_list

    def create
      @deletion_request = ListDeletionRequest.create!(deletion_request_params)
      # NotificationMailer.list_deletion_request_email(@deletion_request).deliver_later
      redirect_to home_dashboard_path, notice: 'Deletion request sent to admins.'
    end

    private

    def deletion_request_params
      {
        user: current_user,
        list: @list,
        justification: params.require('justification')
      }
    end

    def set_deletion_request
      @deletion_request = ListDeletionRequest.find(params.require(:id))
    end

    def set_list
      @list =
        @deletion_request&.list ||
        List.find(params.require(:list_id))
    end
  end
end
