class IndustriesController < ApplicationController
  include Rails.application.routes.url_helpers

  before_action :auth, except: [:show]
  before_action :admins_only, except: [:show]
  before_action :set_industry, only: [:show]

  def show
    @table = IndustryDatatable.new(@industry)
  end

  private

  def set_industry
    @industry = Industry.find(params[:id])
  end
end