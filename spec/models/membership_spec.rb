describe Membership do
  it { is_expected.to belong_to(:relationship) }
  it { is_expected.to have_db_column(:dues) }
  it { is_expected.to have_db_column(:elected_term) }

  describe 'with_elected_term' do
    let(:elected) { create(:elected) }
    let(:us_senate) { create(:us_senate) }
    let(:elected_term_struct) { OpenStruct.new(state: 'NY', party: 'Republican') }

    before do
      Relationship
        .create!(category_id: Relationship::MEMBERSHIP_CATEGORY, entity: elected, related: us_senate)
        .tap { |relationship| relationship.membership.update!(elected_term: elected_term_struct) }

      Relationship
        .create!(category_id: Relationship::MEMBERSHIP_CATEGORY, entity: elected, related: create(:entity_org))
    end

    specify do
      expect(Membership.count).to eq 2
      expect(Membership.with_elected_term.count).to eq 1
    end
  end
end
