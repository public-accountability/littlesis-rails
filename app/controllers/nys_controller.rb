# frozen_string_literal: true

class NYSController < ApplicationController
  include StreamingController
  # before_action :authenticate_user!, :admins_only
  before_action :set_nys_filer

  rescue_from Exceptions::NotFoundError do
    render plain: 'NYS Commitee Not Found'
  end

  # /nys/committee/:id
  # Pfizer: 5060
  # REBY: 6884
  def committee
  end

  # /nys/committee/:id/contributions
  def contributions
    stream_active_record_csv(
      ExternalDataset.nys_disclosures
        .where()
        .where(filer_id: @nys_filer.filer_id)
    )
  end

  private

  def set_nys_filer
    @nys_filer = NYSFilerPresenter.new ExternalDataset.nys_filers.find_by(filer_id: params[:id])
    raise Exceptions::NotFoundError if @nys_filer.nil?
  end
end
