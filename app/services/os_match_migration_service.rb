# frozen_string_literal: true

# Converts OsMatch to an FECMatch
module OsMatchMigrationService
  def self.run
    stats = { missing: 0, already_imported: 0, missing_donor: 0, error: 0, created: 0 }

    OsMatch.find_each do |os_match|
      result = run_one(os_match)
      stats[result] += 1
    end

    Rails.logger.info(stats)
  end

  # return symbols: missing, already_imported, missing_donor, created, error
  def self.run_one(os_match)
    # fec trans id in OsDonation  = sub_id in new fec tables
    fec_trans_id = os_match.os_donation.fectransid.to_i
    fec_contribution = ExternalDataset.fec_contributions.find_by(sub_id: fec_trans_id)
    fec_contribution ||= find_by_os_donation_attributes(os_match.os_donation)

    if fec_contribution.nil?
      return :missing
    elsif FECMatch.exists?(sub_id: fec_trans_id)
      return :already_imported
    elsif os_match.donor.nil?
      Rails.logger.warn "OsMatch (#{os_match.id}) is missing a donor"
      return :missing_donor
    end

    FECMatch.create!(fec_contribution: fec_contribution, donor: os_match.donor)

    :created
  rescue => e
    Rails.logger.warn "OsMatch (#{os_match.id}) Error: #{e.message}. Line: #{e.backtrace[0]}"
    :error
  end

  # For some contributions, the fec id has changed, but the donation is the same
  private_class_method def self.find_by_os_donation_attributes(os_donation)
    ExternalDataset.fec_contributions.find_by(
      name: os_donation.contrib,
      fec_year: os_donation.cycle.to_i,
      cmte_id: os_donation.cmteid,
      transaction_dt: os_donation.date.strftime("%m%d%Y"),
      transaction_tp: os_donation.transactiontype,
      transaction_amt: os_donation.amount,
      city: os_donation.city,
      state: os_donation.state,
      zip_code: os_donation.zip
    )
  end
end
