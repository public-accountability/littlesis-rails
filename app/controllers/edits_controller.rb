# frozen_string_literal: true

class EditsController < ApplicationController
  before_action :authenticate_user!, :block_restricted_user_access
  before_action :set_page, only: [:index, :entity]
  before_action :set_entity, only: [:entity]

  def index
    @without_system_users = true
    @without_system_users = false if params[:without_system_users]&.downcase == 'false'
  end

  def entity
  end

  # turbo stream for recent edits
  def dashboard_edits
    user_id = params.require(:user_id)
    page = params[:page]&.to_i || 1
    render partial: 'dashboard_recent_edits', locals: { page: page, user_id: user_id }
  end
end
