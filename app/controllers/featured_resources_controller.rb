# frozen_string_literal: true

class FeaturedResourcesController < ApplicationController
  before_action :authenticate_user!, :admins_only

  def create
  end

  def destroy
  end
end
