# frozen_string_literal: true

module ECContributionsQuery
  def self.run(entity)
    ExternalRelationship
      .include(:external_data)
      .fec_contributions
      .matched
      .where(entity1: entity)
  end
end
