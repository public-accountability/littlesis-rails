# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authenticate_user!, :admins_only

  def home
    @requests = UserRequestsGrid.new(params[:user_requests_grid]) do |scope|
      scope.page(params[:requests_page] || 1).per(10)
    end

    @users = UserSignupsGrid.new do |scope|
      scope.page(params[:user_signups_page] || 1).per(10)
    end
  end

  def tags
  end

  def stats
    @page = params.fetch('page', 1)
    @time = params.fetch('time', 'week')
  end

  def test
  end

  def entity_matcher
  end

  def tracker
    expires_in 20.minutes, public: false
    render file: Rails.root.join('data/tracker/index.html'), layout: false
  end
end
