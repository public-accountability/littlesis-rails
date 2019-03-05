# frozen_string_literal: true

class ExternalDatasetsController < ApplicationController
  before_action :load_row, only: %i[row matches]

  def index
  end

  def iapd
  end

  def row
    render json: @row.row_data
  end

  def matches
    render json: @row.matches
  end

  private

  def load_row
    @row = ExternalDataset.find(params[:id])
  end
end
