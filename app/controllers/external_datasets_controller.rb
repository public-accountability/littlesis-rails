# frozen_string_literal: true

class ExternalDatasetsController < ApplicationController
  def index
  end

  def iapd
  end

  def row
    render json: ExternalDataset.find(params[:id]).row_data
  end
end
