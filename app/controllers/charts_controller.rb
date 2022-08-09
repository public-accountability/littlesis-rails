# frozen_string_literal: true

class ChartsController < ApplicationController
  before_action :authenticate_user!, -> { check_ability :datasets }

  def sankey
  end
end
