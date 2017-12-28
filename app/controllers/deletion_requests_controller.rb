class DeletionRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deletion_request, only: :review

  def review; end

  private

  def set_deletion_request
    @deletion_request = DeletionRequest.find(params.require(:id).to_i)
  end
end
