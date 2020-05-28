# frozen_string_literal: true

class ExternalDataController < ApplicationController

  # GET /external_data/<dataset>
  def dataset
    service = DatatablesService.new(params.to_unsafe_h)
    render json: service.results
  end

end
