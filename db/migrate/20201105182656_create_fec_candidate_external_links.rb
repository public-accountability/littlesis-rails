class CreateFECCandidateExternalLinks < ActiveRecord::Migration[6.0]
  def change
    ElectedRepresentative.where("fec_ids is not null").each do |er|
      er.fec_ids.each do |fec_candidate_id|
        ExternalLink
          .fec_candidate
          .find_or_create_by!(entity: er.entity, link_id: fec_candidate_id)
      end
    end
  end
end
