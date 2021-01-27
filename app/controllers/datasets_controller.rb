# frozen_string_literal: true

class DatasetsController < ApplicationController
  before_action :authenticate_user!
  before_action -> { @dataset = ExternalDataset.datasets.fetch(params[:dataset].to_sym) }, only: [:show]

  def index
  end

  def show
    grid_class = ExternalDataset.const_get("#{@dataset.dataset_name.to_s.classify}Grid")
    grid_params = params.fetch(grid_class.name.underscore.tr('/', '_'), {}).permit!

    @grid = grid_class.new(grid_params) do |scope|
      scope.page(params[:page] || 1)
    end
    render @dataset.dataset_name
  end

  def dataset
    @dataset = params.require(:dataset)
    @matched = params[:matched]&.to_sym || :all
  end
end
