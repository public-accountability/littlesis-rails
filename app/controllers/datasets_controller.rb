# frozen_string_literal: true

class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def dataset
    @dataset = params.require(:dataset)
    @matched = params[:matched]&.to_sym || :all
  end
end
