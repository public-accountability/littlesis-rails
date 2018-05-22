# frozen_string_literal: true

class DashboardBulletinsController < ApplicationController
  before_action :authenticate_user!
  before_action :admins_only

  def new
  end
end
