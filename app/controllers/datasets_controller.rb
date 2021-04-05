# frozen_string_literal: true

class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @dataset = ExternalDataset.datasets.fetch(params[:dataset].to_sym) # class (i.e. ExternalDataset::FECContribution)
    @grid_class = ExternalDataset.const_get("#{@dataset.dataset_name.to_s.classify}Grid") # class (i.e. ExternalDataset::FECContributionGrid)
    @grid_params_key = @grid_class.name.underscore.tr('/', '_').to_sym # symbol (ie. :external_dataset_fec_contribution_grid)
    @grid_params = params.fetch(@grid_params_key, {}).permit!
    @grid = @grid_class.new(@grid_params)

    respond_to do |f|
      f.html do
        @grid.scope { |scope| scope.page(params[:page] || 1).per(25) }
      end
      f.csv do
        # prevents downloading csvs with more than 100k rows
        return head(:payload_too_large) if @grid.assets.count > 100_000

        # @grid.scope { |scope| scope.order(fec_year: :desc, sub_id: :desc) }

        send_data(@grid.to_csv,
                  type: 'text/csv',
                  disposition: 'inline',
                  filename: "#{@dataset.dataset_name}-#{Time.current.to_i}.csv")
      end
    end
  end
end
