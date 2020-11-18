# frozen_string_literal: true

# Transfers FEC data from the sqlite3 fec database to mysql
#   FEC::Candidate --> ExternalData.fec_candidate
#   FEC::Committee --> ExternalData.fec_committee
#   FEC::IndividualContribution --> ExternalData.fec_contribution
module FECImporter
  THREAD_COUNT = 6

  def self.run
    FEC::Database.establish_connection
    log 'Importing Candidates'
    import_candidates
    log 'Importing Committees'
    import_committees
    log 'Importing Contributions'
    import_contributions
    log 'Creating FEC Donors'
    create_fec_donors
  end

  def self.import_candidates
    FEC::Candidate.all_candidates.each do |candidate|
      ExternalData.fec_candidate.find_or_initialize_by(dataset_id: candidate.CAND_ID).tap do |ed|
        if should_update?(candidate, ed)
          ed.merge_data(candidate.attributes).save!
          ExternalEntity.fec_candidate.find_or_create_by!(external_data: ed)
        end
      end
    end
  end

  def self.import_committees
    FEC::Committee.order(:FEC_YEAR).find_each do |committee|
      ExternalData::Datasets::FECCommittee.import_or_update(committee)
    end
  end

  def self.import_contributions
    # dataset_ids = Concurrent::Set.new ExternalData.fec_contribution.pluck(:dataset_id).map(&:to_i)

    FEC::IndividualContribution.importable_transactions.find_in_batches(batch_size: 10_000) do |batch|
      Parallel.each(batch, in_threads: THREAD_COUNT) do |ic|
        ExternalData.connection_pool.with_connection do
          ExternalData::Datasets::FECContribution.import_or_update(ic)
        end
      end
    end
  end

  def self.create_fec_donors
    ExternalData::CreateFECDonorsService.run
  end

  private_class_method def self.should_update?(fec_model, external_data)
    return true unless external_data.persisted?
    return true if external_data.data['FEC_YEAR'].blank?

    fec_model.FEC_YEAR >= external_data['FEC_YEAR'].to_i
  end

  private_class_method def self.log(msg)
    Rails.logger.info msg
  end
end
