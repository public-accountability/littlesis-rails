describe RelationshipLabel do
  subject { RelationshipLabel.new(relationship).label }

  let(:relationship) { build(:relationship, category_id: 1) }

  context 'with position relationship' do
    let(:relationship) { build(:position_relationship, description1: 'Director') }

    it { is_expected.to eql 'Director' }
  end

  context 'with membership relationship' do
    let(:relationship) { build(:membership_relationship) }

    it { is_expected.to eql 'Member' }
  end

  describe 'donation relationships' do
    context 'with campaign contribution' do
      let(:relationship) do
        build(:donation_relationship,
              filings: nil, amount: 2_000_000, currency: 'USD', description1: "Campaign Contribution")
      end

      it { is_expected.to eql "Donation · 2,000,000 USD" }
    end

    context 'with NYS campaign contribution' do
      let(:relationship) do
        build(:donation_relationship,
              filings: nil, amount: 1_000_000, currency: 'USD', description1: "NYS Campaign Contribution")
      end

      it { is_expected.to eql "NYS Campaign Contribution · 1,000,000 USD" }
    end

    context 'with NYS campaign contribution with 2 filings' do
      let(:relationship) do
        build(:donation_relationship,
              filings: 2, amount: 1_000_000, currency: 'USD', description1: "NYS Campaign Contribution")
      end

      it { is_expected.to eql "2 contributions · 1,000,000 USD" }
    end

    context 'with miscellaneous donation' do
      let(:relationship) do
        build(:donation_relationship, filings: nil, amount: 1000, currency: 'USD', description1: nil)
      end

      it { is_expected.to eql "Donation/Grant · 1,000 USD" }
    end

    context 'with miscellaneous donation having a custom type' do
      let(:relationship) do
        build(:donation_relationship,
              filings: nil, amount: 1000, currency: 'USD', description1: 'suspicious contribution')
      end

      it { is_expected.to eql "suspicious contribution · 1,000 USD" }
    end
  end

  context 'with education relationship' do
    let(:education) { build(:education, degree_id: 2, field: nil) }
    let(:description1) { nil }
    let(:relationship) do
      build(:education_relationship, education: education, description1: description1)
    end

    context 'when degree abbreviation exists' do
      it { is_expected.to eql "BA" }
    end

    context 'when degree abbreviation exists with a field' do
      let(:education) { build(:education, degree_id: 2, field: 'Psychology') }

      it { is_expected.to eql "BA, Psychology" }
    end

    context 'when abbreviation exists' do
      let(:education) { build(:education, degree_id: 12, field: nil) }
      let(:relationship) do
        build(:education_relationship, education: education, description1: description1)
      end

      it 'shows full degree name' do
        expect(subject).to eql "Honorus Degree"
      end
    end

    context 'when relationship has description1 but no field or degree' do
      let(:education) { build(:education, degree_id: nil, field: nil) }
      let(:description1) { 'Undergraduate' }

      it { is_expected.to eql "Undergraduate" }
    end

    describe 'showing default description' do
      let(:education) { build(:education, degree_id: nil, field: nil) }

      it { is_expected.to eql "School" }
    end

    describe 'reversed default description' do
      subject { RelationshipLabel.new(relationship, true).label }

      let(:education) { build(:education, degree_id: nil, field: nil) }

      it { is_expected.to eql "Student" }
    end

    context 'when education is missing' do
      let(:relationship) { build(:education_relationship, education: nil) }

      it { is_expected.to eql "School" }
    end
  end

  describe 'service/transaction relationship' do
    context 'without amount' do
      let(:relationship) do
        build(:transaction_relationship, amount: nil, description1: 'Contractor', description2: 'Client')
      end

      it { is_expected.to eql "Client" }

      describe 'reversed relationship' do
        subject { RelationshipLabel.new(relationship, true).label }

        it { is_expected.to eql "Contractor" }
      end
    end

    context 'with amount' do
      context 'with description1' do
        let(:relationship) do
          build(:transaction_relationship, amount: 10_000, currency: 'USD', description1: 'Contractor', description2: 'Client')
        end

        it { is_expected.to eql "Client · 10,000 USD" }
      end

      context 'without description1' do
        let(:relationship) do
          build(:transaction_relationship, amount: 10_000, currency: 'USD', description1: '', description2: '')
        end

        it { is_expected.to eql "Service/Transaction · 10,000 USD" }
      end
    end
  end

  describe 'social relationships' do
    context 'when description fields are filled out' do
      let(:relationship) do
        build(:social_relationship, description1: 'friend', description2: 'buddy')
      end

      describe 'when normal (not reversed)' do
        subject { RelationshipLabel.new(relationship, false).label }

        it { is_expected.to eql "buddy" }
      end

      describe 'reversed' do
        subject { RelationshipLabel.new(relationship, true).label }

        it { is_expected.to eql "friend" }
      end
    end

    context 'when description fields are empty' do
      let(:relationship) { build(:social_relationship, description1: nil, description2: nil) }

      it { is_expected.to eql "Social" }
    end
  end

  describe '#label_for_page_of' do
    subject(:rlabel) { RelationshipLabel.new(relationship) }

    let(:entity_one) { build(:person) }
    let(:entity_two) { build(:person) }
    let(:relationship) do
      build(:social_relationship, entity: entity_one, related: entity_two, description1: 'friend', description2: 'buddy')
    end

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

    context 'when donation relationship has filings' do
      let(:relationship) { build(:donation_relationship, filings: 3, amount: 1000, currency: 'USD') }

      it { is_expected.to eql "3 contributions · 1,000 USD" }
    end

    context 'when filings is nil' do
      let(:relationship) { build(:donation_relationship, filings: nil, amount: 2_000_000, currency: 'USD') }

      it { is_expected.to eql "Donation/Grant · 2,000,000 USD" }
    end

    context 'when filing is 0' do
      let(:relationship) do
        build(:donation_relationship,
              filings: 0, amount: 2_000_000, currency: 'USD', description1: 'Campaign Contribution')
      end

      it { is_expected.to eql "Donation · 2,000,000 USD" }
    end
  end

  describe '#display_date_range' do
    subject { RelationshipLabel.new(rel).display_date_range }

    let(:start_date) { nil }
    let(:end_date) { nil }
    let(:is_current) { nil }
    let(:category_id) { 12 }
    let(:rel) do
      build(:relationship, start_date: start_date, end_date: end_date, is_current: is_current, category_id: category_id)
    end

    context 'when a past relationship has no start or end dates' do
      let(:is_current) { false }

      it { is_expected.to eql '(past)' }
    end

    context 'when a current relationship has no start or end dates' do
      let(:is_current) { true }

      it { is_expected.to eql '' }
    end

    context 'when start date and end date are equal' do
      let(:start_date) { '1999-00-00' }
      let(:end_date) { '1999-00-00' }

      it { is_expected.to eql "('99)" }
    end

    context 'when relationship is a donation relationship and missing an end date' do
      let(:category_id) { 5 }
      let(:start_date) { '1999-02-25' }

      it { is_expected.to eql "(Feb 25 '99)" }
    end

    context 'has start and end date' do
      let(:start_date) { '2000-01-01' }
      let(:end_date) { '2012-12-12' }

      it { is_expected.to eql "(Jan 1 '00→Dec 12 '12)" }
    end

    context 'when the relationship start date is invalid' do
      let(:start_date) { '2000' }

      it { is_expected.to eql '' }
    end
  end
  
end
