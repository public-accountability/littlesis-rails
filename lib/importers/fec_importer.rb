# frozen_string_literal: true

module FECImporter
  def self.run
    import_candidates
    import_committees
  end

  def self.import_candidates
    FEC::Database.establish_connection

    Parallel.each(FEC::Candidate.order(:FEC_YEAR).find_in_batches) do |candidates|
      candidates.each do |candidate|
        ExternalData.fec_candidate.find_or_initialize_by!(dataset_id: candidate.CAND_ID).tap do |ed|
          ed.merge_data(candidate.attributes).save! if should_update?(candidate, ed)
        end
      end
    end
  end

  def self.import_committees
    FEC::Database.establish_connection

    Parallel.each(FEC::Committee.order(:FEC_YEAR).find_in_batches) do |committees|
      committees.each do |committee|
        ExternalData.fec_committee.find_or_initialize_by!(dataset_id: committee.committee_id).tap do |ed|
          ed.merge_data(candidate.attributes).save! if should_update?(committee, ed)
        end
      end
    end
  end

  private_class_method def self.should_update?(fec_model, external_data)
    return true if !external_data.persisted? || external_data.data['FEC_YEAR'].empty?

    fec_model.FEC_YEAR >= external_data['FEC_YEAR'].to_i
  end
end
