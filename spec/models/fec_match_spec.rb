describe FECMatch do
  let(:fec_contribution) { create(:external_dataset_fec_contribution) }
  let(:fec_committee) { create(:external_dataset_fec_committee) }
  let(:donor) { create(:entity_person, :with_person_name) }
  let(:committee_entity) do
    create(:entity_org, name: fec_committee.cmte_nm.titleize).tap do |e|
      e.external_links.create!(link_type: :fec_committee, link_id: fec_committee.cmte_id)
    end
  end

  let(:candidate) do
    create(:entity_person, name: 'Barack Obama').tap do |e|
      e.external_links.create!(link_type: :fec_candidate, link_id: fec_committee.cand_id)
    end
  end

  describe 'validations' do
    it { is_expected.to have_db_column(:sub_id) }
    it { is_expected.to have_db_column(:donor_id) }
    it { is_expected.to have_db_column(:recipient_id) }
    it { is_expected.to have_db_column(:committee_relationship_id) }
    it { is_expected.to have_db_column(:candidate_relationship_id) }
  end

  it 'creates committee relationships' do
    fec_contribution; fec_committee; donor; committee_entity;
    expect(Relationship.exists?(entity1_id: donor.id, entity2_id: committee_entity.id)).to be false
    FECMatch.create!(fec_contribution: fec_contribution, donor: donor, recipient: committee_entity)
    expect(Relationship.exists?(entity1_id: donor.id, entity2_id: committee_entity.id)).to be true
  end

  it 'finds existing committee relationships' do
    fec_contribution; fec_committee; donor; committee_entity;
    rel = Relationship.create!(entity: donor, related: committee_entity, category_id: Relationship::DONATION_CATEGORY, description1: 'Campaign Contribution')
    expect { FECMatch.create!(fec_contribution: fec_contribution, donor: donor, recipient: committee_entity) }.not_to change(Relationship, :count)
    fec_match = FECMatch.last
    expect(fec_match.committee_relationship).to eq rel
    expect(fec_match.candidate_relationship).to be nil
  end

  it 'creates candidate relationships' do
    fec_contribution; fec_committee; donor; committee_entity; candidate;
    expect(Relationship.exists?(entity1_id: donor.id, entity2_id: candidate)).to be false
    FECMatch.create!(fec_contribution: fec_contribution, donor: donor, recipient: committee_entity, candidate: candidate)
    expect(Relationship.exists?(entity1_id: donor.id, entity2_id: candidate.id)).to be true
  end

  it 'finds existing commitee & candidate relationships' do
    fec_contribution; fec_committee; donor; committee_entity; candidate;
    committee_r = Relationship.create!(entity: donor, related: committee_entity, category_id: Relationship::DONATION_CATEGORY, description1: 'Campaign Contribution')
    candidate_r = Relationship.create!(entity: donor, related: candidate, category_id: Relationship::DONATION_CATEGORY, description1: 'Campaign Contribution')
    expect { FECMatch.create!(fec_contribution: fec_contribution, donor: donor, recipient: committee_entity, candidate: candidate) }.not_to change(Relationship, :count)
    fec_match = FECMatch.last
    expect(fec_match.committee_relationship).to eq committee_r
    expect(fec_match.candidate_relationship).to eq candidate_r
  end

  it 'finds existing recipient'
  it 'creates new recipient if needed'
end
