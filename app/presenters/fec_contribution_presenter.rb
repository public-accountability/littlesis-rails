# frozen_string_literal: true

class FECContributionPresenter < SimpleDelegator
  def amount
    ActiveSupport::NumberHelper.number_to_currency(transaction_amt, precision: 0)
  end

  def employment
    if occupation.present? && employer.present?
      "#{occupation} - #{employer}"
    end
  end

  def location
    "#{city}, #{state}, #{zip_code}"
  end

  def recipient
    if fec_committee.entity
      fec_committee.entity.name
    else
      fec_committee.cmte_nm
    end
  end

  def transaction_type_description
    ExternalDataset::FECContribution::TRANSACTION_TYPES[transaction_tp].to_s.tr('_', ' ')
  end
end
