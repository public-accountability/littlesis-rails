require 'rails_helper'

describe NyDisclosure, type: :model do
  it { should have_one(:ny_match) }
  it { should belong_to(:ny_filer) }
  it { should validate_presence_of(:filer_id) }
  it { should validate_presence_of(:report_id) }
  it { should validate_presence_of(:transaction_code) }
  it { should validate_presence_of(:e_year) }
  it { should validate_presence_of(:transaction_id) }
  it { should validate_presence_of(:schedule_transaction_date) }

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

  describe 'search_terms' do
    def build_entity(name)
      e = build(:person)
      a = build(:alias, name: name, is_primary: true)
      allow(e).to receive(:aliases).and_return([a])
      return e
    end

    it 'Returns name if the name has no middle, suffix, or preface' do
      e = build_entity('Alice Coltrane')
      expect(NyDisclosure.search_terms(e)).to eql 'Alice Coltrane'
    end

    it 'Adds first and last only term if middle name exists' do
      e = build_entity('Alice X Coltrane')
      expect(NyDisclosure.search_terms(e)).to eql 'Alice X Coltrane | Alice Coltrane'
    end

    it 'Adds first and last only term if suffix exists' do
      e = build_entity('Alice Coltrane JR')
      expect(NyDisclosure.search_terms(e)).to eql 'Alice Coltrane JR | Alice Coltrane'
    end

    it 'Adds both Aliases' do
      e = build(:person)
      a1 = build(:alias, name: "Alice Coltrane JR", is_primary: true)
      a2 = build(:alias, name: "Al Coltrane", is_primary: false)
      allow(e).to receive(:aliases).and_return([a1, a2])
      expect(NyDisclosure.search_terms(e)).to eql 'Alice Coltrane JR | Alice Coltrane | Al Coltrane'
    end
  end
end
