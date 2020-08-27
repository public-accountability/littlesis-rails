# frozen_string_literal: true

module DeletionRequests
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :admins_only, only: [:review, :commit_review]
    before_action :set_deletion_request, only: [:review, :commit_review]
    before_action :set_decision, only: :commit_review

    # GET /deletion_requests/new
    def new; end

    # POST /deletion_requests
    def create
      NotificationMailer.deletion_request_email(@deletion_request).deliver_later
      redirect_to home_dashboard_path, notice: 'Deletion request sent to admins.'
    end

    # GET /deletion_requests/:id/review
    def review; end

    # POST /deletion_reqeusts/:id/review
    def commit_review
      @deletion_request.send("#{@decision}_by!".to_sym, current_user)
      redirect_to home_dashboard_path, notice: "Deletion request #{@decision}"
    end

    private

    def set_decision
      @decision = %w[approved denied].delete(params.require(:decision))
    end
  end
end
