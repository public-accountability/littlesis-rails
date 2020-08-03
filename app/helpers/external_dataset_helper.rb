# frozen_string_literal: true

module ExternalDatasetHelper
  def render_columns_js(dataset)
    render partial: "datasets/dataset_columns/#{dataset}", formats: [:js]
  end

  def nys_disclosure_transaction_code_options
    container = NYSCampaignFinance::TRANSACTION_CODE_OPTIONS.keys.map do |name|
      [name.to_s.tr('_', ' ').titleize, name]
    end

    options_for_select container, ['contributions']
  end

  def external_dataset_iapd_subtitle(flow)
    dataset_name = flow.gsub('owners', 'executives')

    content_tag(:h2, class: 'mt-1') do
      content_tag(:b, 'Dataset: ') + content_tag(:span, "IAPD #{dataset_name}")
    end
  end
end
