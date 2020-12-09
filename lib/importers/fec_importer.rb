# frozen_string_literal: true

# Transfers FEC data from the sqlite3 fec database to mysql
#   FEC::Candidate --> ExternalData.fec_candidate
#   FEC::Committee --> ExternalData.fec_committee
#   FEC::IndividualContribution --> ExternalData.fec_contribution
# Generates ExternalData.fec_donor from ExternalData.fec_contribution
module FECImporter
  BATCH_SIZE = 10_000
  THREAD_COUNT = 6

  def self.run
    FEC::Database.establish_connection
    Parallel.each(%i[import_candidates import_committees], in_processes: 2) { |m| public_send(m) }
    # import_contributions(scope: :large_transactions)
    import_contributions
    ExternalData.services.create_fec_donors
  end

  def self.import_candidates
    Rails.logger.info 'Importing Candidates'
    FEC::Candidate.all_candidates.each do |candidate|
      ExternalData::Datasets::FECCandidate.import_or_update(candidate)
    end
  end

  def self.import_committees
    Rails.logger.info 'Importing Committees'
    FEC::Committee.order(:FEC_YEAR).find_each do |committee|
      ExternalData::Datasets::FECCommittee.import_or_update(committee)
    end
  end

  # pass in :large_transactions to limit to transactions over 1500
  def self.import_contributions(scope: :itself)
    Rails.logger.info 'Importing Contributions'
    FEC::IndividualContribution.importable_transactions.public_send(scope).find_in_batches(batch_size: 10_000) do |batch|
      Parallel.each(batch, in_threads: THREAD_COUNT) do |ic|
        ExternalData.connection_pool.with_connection do
          ExternalData::Datasets::FECContribution.import_or_update(ic)
        end
      end
    end
  end
end
