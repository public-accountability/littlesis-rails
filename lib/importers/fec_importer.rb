# frozen_string_literal: true

module FECImporter
  def self.run
    FEC::Database.establish_connection

    tasks = [:import_candidates, :import_committees, :import_donors]

    Parallel.each(tasks, in_processes: tasks.length) do |task|
      public_send(task)
    end
  end

  def self.import_candidates
    FEC::Candidate.all_candidates.each do |candidate|
      ExternalData.fec_candidate.find_or_initialize_by(dataset_id: candidate.CAND_ID).tap do |ed|
        if should_update?(candidate, ed)
          ed.merge_data(candidate.attributes).save!
          ExternalEntity.fec_candidate.find_or_create_by!(external_data: ed).automatch
        end
      end
    end
  end

  def self.import_committees
    FEC::Committee.order(:FEC_YEAR).find_each do |committee|
      ExternalData.fec_committee.find_or_initialize_by(dataset_id: committee.committee_id).tap do |ed|
        if should_update?(committee, ed)
          ed.merge_data(committee.attributes).save!
          ExternalEntity.fec_committee.find_or_create_by!(external_data: ed).automatch
        end
      end
    end
  end

  def self.import_donors
    FEC::Donors.find_each do |donor|
      ed = ExternalData.fec_donor.find_or_initialize_by!(dataset_id: donor.md5digest)

      unless ed.persisted? # remove this to update
        ed.merge_data(donor.nice).save!
      end

      ExternalEntity.fec_donor.find_or_create_by!(external_data: ed).automatch
    end
  end

  private_class_method def self.should_update?(fec_model, external_data)
    return true unless external_data.persisted?
    return true if external_data.data['FEC_YEAR'].blank?

    fec_model.FEC_YEAR >= external_data['FEC_YEAR'].to_i
  end
end
