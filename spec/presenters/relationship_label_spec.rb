require 'rails_helper'

describe RelationshipLabel do
  let(:relationship) { build(:relationship, category_id: 1) }
  subject { RelationshipLabel.new(relationship).label }

  context 'relationship is a postiion' do
    let(:relationship) { build(:position_relationship, description1: 'Director') }
    it { is_expected.to eql 'Director' }
  end

  context 'relationship is a membership' do
    let(:relationship) { build(:membership_relationship) }
    it { is_expected.to eql 'Member' }
  end

  describe 'donation relationships' do
    context 'campaign contribution' do
      let(:relationship) do
        build(:donation_relationship,
              filings: nil, amount: 2_000_000, description1: "Campaign Contribution")
      end
      it { is_expected.to eql "Donation · $2,000,000" }
    end

    context 'NYS campaign contribution' do
      let(:relationship) do
        build(:donation_relationship,
              filings: nil, amount: 1_000_000, description1: "NYS Campaign Contribution")
        it { is_expected.to eql "NYS Campaign Contribution · $1,000,000" }
      end
    end

    context 'NYS campaign contribution with 2 filings' do
      let(:relationship) do
        build(:donation_relationship,
              filings: 2, amount: 1_000_000, description1: "NYS Campaign Contribution")
        it { is_expected.to eql "2 contributions · $1,000,000" }
      end
    end

    context 'miscellaneous donation' do
      let(:relationship) do
        build(:donation_relationship, filings: nil, amount: 1000, description1: nil)
      end
      it { is_expected.to eql "Donation/Grant · $1,000" }
    end

    context 'miscellaneous donation with custom type' do
      let(:relationship) do
        build(:donation_relationship,
              filings: nil, amount: 1000, description1: 'suspicious contribution')
      end
      it { is_expected.to eql "suspicious contribution · $1,000" }
    end
  end

  context 'education relationship' do
    let(:education) { build(:education, degree_id: 2, field: nil) }
    let(:description1) { nil }
    let(:relationship) do
      build(:education_relationship, education: education, description1: description1)
    end

    context 'degree abbreviation exists' do
      it { is_expected.to eql "BA" }
    end

    context 'degree abbrevation exists with a  field' do
      let(:education) { build(:education, degree_id: 2, field: 'Psychology') }
      it { is_expected.to eql "BA, Psychology" }
    end

    context 'abbreviation exists' do
      let(:education) { build(:education, degree_id: 12, field: nil) }
      let(:relationship) do
        build(:education_relationship, education: education, description1: description1)
      end
      it 'shows full degree name' do
        expect(subject).to eql "Honorus Degree"
      end
    end

    context 'has description1 but no field or degree' do
      let(:education) { build(:education, degree_id: nil, field: nil) }
      let(:description1) { 'Undergraduate' }
      it { is_expected.to eql "Undergraduate" }
    end

    context 'shows default description' do
      let(:education) { build(:education, degree_id: nil, field: nil) }
      it { is_expected.to eql "School" }
    end

    context 'shows default description reversed' do
      let(:education) { build(:education, degree_id: nil, field: nil) }
      subject { RelationshipLabel.new(relationship, true).label }
      it { is_expected.to eql "Student" }
    end

    context 'education is missing' do
      let(:relationship) { build(:education_relationship, education: nil) }
      it { is_expected.to eql "School" }
    end
  end

  context 'social relationships' do
    context 'description fields are filled out' do
      let(:relationship) do
        build(:social_relationship, description1: 'friend', description2: 'buddy')
      end

      context 'normal (not reversed)' do
        subject { RelationshipLabel.new(relationship, false).label }
        it { is_expected.to eql "buddy" }
      end

      context 'reversed' do
        subject { RelationshipLabel.new(relationship, true).label }
        it { is_expected.to eql "friend" }
      end
    end

    context 'description fields are empty' do
      let(:relationship) { build(:social_relationship, description1: nil, description2: nil) }
      it { is_expected.to eql "Social" }
    end
  end

  describe '#label_for_page_of' do
    let(:entity_one) { build(:person) }
    let(:entity_two) { build(:person) }
    let(:relationship) do
      build(:social_relationship, entity: entity_one, related: entity_two, description1: 'friend', description2: 'buddy')
    end

    subject(:rlabel) { RelationshipLabel.new(relationship) }

    describe 'label for entity one' do
      subject { rlabel.label_for_page_of(entity_one) }
      it { is_expected.to eql 'buddy' }
    end

    describe 'label for entity two' do
      subject { rlabel.label_for_page_of(entity_two) }
      it { is_expected.to eql 'friend' }
    end

    specify do
      expect { rlabel.label_for_page_of(entity_two) }.not_to change { rlabel.is_reverse }
    end
  end

  describe '#humanize_contributions' do
    subject { RelationshipLabel.new(relationship).send(:humanize_contributions) }

    context 'donation relationship has filings' do
      let(:relationship) { build(:donation_relationship, filings: 3, amount: 1000) }
      it { is_expected.to eql "3 contributions · $1,000" }
    end

    context 'filings is nil' do
      let(:relationship) { build(:donation_relationship, filings: nil, amount: 2_000_000) }
      it { is_expected.to eql "Donation/Grant · $2,000,000" }
    end

    context 'filing is 0' do
      let(:relationship) do
        build(:donation_relationship,
              filings: 0, amount: 2_000_000, description1: 'Campaign Contribution')
      end
      it { is_expected.to eql "Donation · $2,000,000" }
    end
  end
end
