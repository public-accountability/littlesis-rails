describe FECMatch do
  let(:donor) { create(:entity_person) }
  let(:pac) { create(:entity_org, name: 'pac') }
  let(:fec_match) { build(:fec_match, recipient: pac, donor: donor) }

  let(:existing_relationship) do
    Relationship.create!(category_id: RelationshipCategory.name_to_id[:donation],
                         entity: fec_match.donor,
                         related: pac,
                         description1: 'Campaign Contribution',
                         amount: 3)
  end

  describe 'validation' do
    it { is_expected.to have_db_column(:sub_id) }
    it { is_expected.to have_db_column(:donor_id) }
    it { is_expected.to have_db_column(:recipient_id) }
    it { is_expected.to have_db_column(:candidate_id) }
  end

  describe '#committee_relationship' do
    it 'creates a new relationship relationships' do
      expect { fec_match.save! }.to change(Relationship, :count).by(1)
    end

    it 'finds existing relationship' do
      existing_relationship
      expect { fec_match.save! }.not_to change(Relationship, :count)
      expect(fec_match.committee_relationship).to eq existing_relationship
    end
  end
end
