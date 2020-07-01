describe NyDisclosure, type: :model do
  it { should have_one(:ny_match) }
  it { should belong_to(:ny_filer).optional }
  it { should validate_presence_of(:filer_id) }
  it { should validate_presence_of(:report_id) }
  it { should validate_presence_of(:transaction_code) }
  it { should validate_presence_of(:e_year) }
  it { should validate_presence_of(:transaction_id) }
  it { should validate_presence_of(:schedule_transaction_date) }

  let(:disclosure) do
    build(:ny_disclosure,
          filer_id: "A12498",
          report_id: "E",
          transaction_code: "A",
          e_year: "2006")
  end

  describe '#full_name' do
    it 'returns corp_name if it exists' do
      d = build(:ny_disclosure, corp_name: 'corp inc')
      expect(d.full_name).to eql 'corp inc'
    end

    it 'returns formatted name' do
      d = build(:ny_disclosure, first_name: 'ALICE', last_name: 'COLTRANE')
      expect(d.full_name).to eql 'Alice Coltrane'
      d2 = build(:ny_disclosure, first_name: 'ALICE', last_name: 'COLTRANE', mid_init: 'X')
      expect(d2.full_name).to eql 'Alice X Coltrane'
    end

    it 'returns nil otherwise' do
      d = build(:ny_disclosure)
      expect(d.full_name).to be nil
    end
  end

  describe "#reference_link" do
    it 'returns link to election.ny.gov' do
      expect(disclosure.reference_link)
        .to eq "http://www.elections.ny.gov:8080/reports/rwservlet?cmdkey=efs_sch_report&p_filer_id=A12498&p_e_year=2006&p_freport_id=E&p_transaction_code=A"
    end
  end

  describe "#reference_name" do
    it 'returns reference_name' do
      expect(disclosure.reference_name)
        .to eq "2006 NYS Board of Elections Financial Disclosure Report: 11 Day Pre General"
    end
  end

  describe 'search_terms' do
    def build_entity(name, type)
      e = build(type)
      a = build(:alias, name: name, is_primary: true)
      allow(e).to receive(:aliases).and_return([a])
      return e
    end

    describe 'Dennis R McCoy' do
      let(:dennis) { build_entity("Dennis R McCoy", :person) }

      it 'returns correct search terms' do
        expect(NyDisclosure.search_terms(dennis)).to eq '(Dennis R McCoy) | (Dennis McCoy)'
      end
    end

    context 'searching for a person' do
      it 'Returns name if the name has no middle, suffix, or preface' do
        e = build_entity('Alice Coltrane', :person)
        expect(NyDisclosure.search_terms(e)).to eql 'Alice Coltrane'
      end

      it 'Adds first and last only term if middle name exists' do
        e = build_entity('Alice X Coltrane', :person)
        expect(NyDisclosure.search_terms(e)).to eql '(Alice X Coltrane) | (Alice Coltrane)'
      end

      it 'Adds first and last only term if suffix exists' do
        e = build_entity('Alice Coltrane JR', :person)
        expect(NyDisclosure.search_terms(e)).to eql '(Alice Coltrane JR) | (Alice Coltrane)'
      end

      it 'Adds both Aliases' do
        e = build(:person)
        a1 = build(:alias, name: "Alice Coltrane JR", is_primary: true)
        a2 = build(:alias, name: "Al Coltrane", is_primary: false)
        allow(e).to receive(:aliases).and_return([a1, a2])
        expect(NyDisclosure.search_terms(e))
          .to eql '(Alice Coltrane JR) | (Alice Coltrane) | (Al Coltrane)'
      end
    end

    context 'searching for an org' do
      it 'adds corp name' do
        e = build_entity('apple', :org)
        expect(NyDisclosure.search_terms(e)).to eql 'apple'
      end

      it 'removes common suffix' do
        e = build_entity('evil corp', :org)
        expect(NyDisclosure.search_terms(e)).to eql '(evil corp) | (evil)'
      end
    end
  end
end
