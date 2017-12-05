class AdminController < ApplicationController
  before_filter :authenticate_user!, :admins_only

  def home
  end

  def tags
  end
end
