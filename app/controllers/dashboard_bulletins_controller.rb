# frozen_string_literal: true

class DashboardBulletinsController < ApplicationController
  before_action :authenticate_user!
  before_action :admins_only
  before_action :set_bulletin, only: %i[edit update destroy]

  def index
  end

  def new
  end

  def create
    DashboardBulletin.create!(bulletin_params)
    redirect_to_dashboard
  end

  def edit
  end

  def update
    @bulletin.update!(bulletin_params)
    redirect_to_dashboard
  end

  def destroy
    @bulletin.destroy!
    redirect_to_dashboard
  end

  private

  def set_bulletin
    @bulletin = DashboardBulletin.find(params.require(:id))
  end

  def bulletin_params
    params.require(:dashboard_bulletin).permit(:title, :content, :color).to_h
  end
end
