# frozen_string_literal: true

class ExternalDataController < ApplicationController
  # GET /external_data/<dataset>
  def dataset
    datatables_params = Datatables::Params.new(params)
    render json: ExternalData.datatables_query(datatables_params)
  end
end
