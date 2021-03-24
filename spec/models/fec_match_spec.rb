describe FECMatch do
  describe 'validation' do
    it { is_expected.to have_db_column(:sub_id) }
    it { is_expected.to have_db_column(:donor_id) }
    it { is_expected.to have_db_column(:recipient_id) }
    it { is_expected.to have_db_column(:candidate_id) }
  end

  describe '#committee_relationship' do
    let!(:pac) { create(:entity_org, name: 'pac') }
    let!(:fec_match) { create(:fec_match, recipient: pac) }

    it 'finds existing relationship' do
      relationship = Relationship.create!(category_id: Relationship::DONATION_CATEGORY,
                                          entity: fec_match.donor,
                                          related: pac,
                                          description1: 'Campaign Contribution',
                                          amount: 3)

      expect { fec_match.committee_relationship }.not_to change(Relationship, :count)

      expect(fec_match.committee_relationship).to eq relationship

    end

    it 'creates a new relationship' do
      expect { fec_match.committee_relationship }.to change(Relationship, :count).by(1)
    end
  end
end
