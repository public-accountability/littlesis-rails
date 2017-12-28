class DeletionRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deletion_request, only: [:review, :commit_review]
  before_action :set_decision, only: :commit_review

  # GET /deletion_requests/:id/review
  def review; end

  # POST /deletion_reqeusts/:id/review
  def commit_review
    @deletion_request.send("#{@decision}_by!".to_sym, current_user)
    redirect_to home_dashboard_path, notice: "Deletion request #{@decision}"
  end

  private

  def set_deletion_request
    @deletion_request = DeletionRequest.find(params.require(:id).to_i)
  end

  def set_decision
    @decision = %w[approved denied].delete(params.require(:decision))
  end
end
