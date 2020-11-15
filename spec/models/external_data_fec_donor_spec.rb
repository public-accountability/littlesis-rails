describe 'Matching Donors and Updating Relationships, Candidates, and Committees From FEC Data' do
  # Relationship ---> HasOneOrMany --> donor
  # Donor     --> Committee
  # Donor     --> Candidate (duplicate of committee relationship)

  # Committee ---> Candidate

  # ExternalData.fec_contribution
  #
  # 0 Donor --> foo committee
  # 1 Donor --> foo committee
  # 2 Donor --> bar committee
  # 3.Donor --> pac committee
  let!(:contributions) do
  end

  # ExternalRelationship.fec_contribution
  let!(:contributions_external_relationships) do
    contributions.map(&:external_relationship)
  end

  # ExternalData.fec_donor
  let(:fec_donor) do
  end

  # ExternalEntity.fec_donor
  let(:donor_external_entity) do
    donor.external_entity
  end

  # ExternalData.fec_committee
  # let(:foo_fec_committee) do
  # end

  # let(:bar_fec_committee) do
  # end

  # let(:pac_fec_committee) do
  # end

  # ExternalData.fec_candidate
  let(:foo_fec_candidate) do
  end

  let(:bar_fec_candidate) do
  end

  let(:entity_donor) do
    create(:entity_person)
  end

  let(:entity_foo_committee)
  let(:entity_bar_committee)
  let(:entity_pac_committee)

  describe 'Match Donors' do
    specify 'Matching donations' do
      # expect(Relationship.exist?(entity: entity_donor, related: foo_fec_committee)).to be_false
      # expect(Relationship.exist?(entity: entity_donor, reltaed: foo_fec_candidate)).to be_false
      # expect(contributions[0].external_relationship.matched?).to be_false

      # contributions[0].external_relationship.match_entity1_with entity_donor

      # expect(contributions[0].external_relationship.matched?).to be_true
      # expect(Relationship.exist?(entity: entity_donor, related: foo_fec_committee)).to be_true
      # expect(Relationship.find_by(entity: entity_donor, related: foo_fec_candidate).amount).to eq 100

      # contributions[1].external_relationship.match_entity1_with entity_donor

      # expect(Relationship.where(entity: entity_donor, related: foo_fec_committee).count).to eq 1
      # expect(Relationship.find_by(entity: entity_donor, related: foo_fec_committee).amount).to eq 200
      # expect(Relationship.find_by(entity: entity_donor, related: foo_fec_candidate).amount).to eq 200

      # expect(Relationship.exist?(entity: entity_donor, related: pac_committee)).to be_false

      # contributions[2].external_relationship.match_entity1_with entity_donor
    end
  end
end
