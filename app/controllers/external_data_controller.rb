# frozen_string_literal: true

class ExternalDataController < ApplicationController

  # GET /external_data/<dataset>
  def dataset
    render json: ExternalData.datatables_query(Datatables::Params.new(params))
  end

end
