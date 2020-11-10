# frozen_string_literal: true

class FECDonorMatchService
  def self.run(donor_id:, sub_ids:)
    @donor = Entity.find_with_merges(donor_id)
    @sub_ids = Array.wrap(sub_ids).map(&:to_i)

    ExternalData
      .includes(:external_relationships)
      .fec_contribution
      .where(dataset_id: [sub_ids])
      .map(&:external_relationships)
      .each { |er| er.match_entity1_with donor }
  end
end
