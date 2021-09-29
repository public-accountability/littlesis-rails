# frozen_string_literal: true

module ExternalDatasetHelper
  def nys_disclosure_transaction_code_options
    container = NYSCampaignFinance::TRANSACTION_CODE_OPTIONS.keys.map do |name|
      [name.to_s.tr('_', ' ').titleize, name]
    end

    options_for_select container, ['contributions']
  end
end
