# frozen_string_literal: true

class ChartsController < ApplicationController
  before_action :authenticate_user!, -> { check_ability :view_experiments }

  def sankey
  end
end
