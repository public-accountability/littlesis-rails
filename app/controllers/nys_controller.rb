# frozen_string_literal: true

class NYSController < ApplicationController
  include ActionController::Live
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
    transaction_filter = if params[:transaction_code]
                           { :filing_sched_abbrev => NYSCampaignFinance::TRANSACTION_CODE_OPTIONS.fetch(params[:transaction_code].downcase.to_sym) }
                         end

    filename = +"nys_disclosures"
    filename << "_#{params[:transaction_code]}" if transaction_filter
    filename << ".csv"

    stream_active_record_csv(
      ExternalDataset.nys_disclosures.where(filer_id: @nys_filer.filer_id).where(transaction_filter),
      filename: filename
    )
  end

  private

  def set_nys_filer
    @nys_filer = NYSFilerPresenter.new ExternalDataset.nys_filers.find_by(filer_id: params[:id])
    raise Exceptions::NotFoundError if @nys_filer.nil?
  end
end
