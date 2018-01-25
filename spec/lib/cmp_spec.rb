require "rails_helper"

describe Cmp do
  describe Cmp::CmpEntityImporter do
    let(:attrs) { LsHash.new(name: Faker::Cat.name) }
    subject { Cmp::CmpEntityImporter.new attrs }
    specify { expect(subject.attributes).to eql attrs }
  end

  describe Cmp::ExcelSheet do
    class TestCmpExcelSheet < Cmp::ExcelSheet
      HEADER_MAP = { cmpid: 'CMPID_ORGL', cmpname: 'CMPName' }.freeze
    end

    let(:excel_file_path) { Rails.root.join('spec', 'testdata', 'cmp_orgs.xlsx').to_s }

    subject { TestCmpExcelSheet.new(excel_file_path) }

    it 'parses excel sheet into an array of hash according to the header converstion map' do
      expect(subject.to_a)
        .to eql [{ cmpid: 5_100_178, cmpname: 'BNP PARIBAS' }, { cmpid: 5_100_179, cmpname: 'TELEFONICA SA' }]
    end
  end

  describe Cmp::OrgType do
    it 'has TYPES consant' do
      expect(Cmp::OrgType::TYPES).to be_a Hash
    end

    it 'raises error if passed an type id that is out of range' do
      expect { Cmp::OrgType.new(0) }.to raise_error(ArgumentError)
      expect { Cmp::OrgType.new(10) }.to raise_error(ArgumentError)
    end

    it 'sets extension and name properly' do
      org_type = Cmp::OrgType.new('9')
      expect(org_type.name).to eql 'Corporation'
      expect(org_type.extension).to eql 'Business'
      expect(org_type.type_id).to eql 9
    end
  end

  describe Cmp::EntityMatch do
    let(:entity_match) { Cmp::EntityMatch.new(name: 'test name', primary_ext: 'Person', cmpid: 123) }

    it 'EntityMatch.matches return hash of all manual matches' do
      expect(Cmp::EntityMatch.matches).to be_a Hash
      expect(Cmp::EntityMatch::MATCHES.length).to be > 25
    end

    it 'raises error if passed invalid type' do
      expect do
        Cmp::EntityMatch.new(name: 'name', primary_ext: 'invalid primary ext')
      end.to raise_error(ArgumentError)
    end

    it 'sets @name, @search_options, and @cmpid' do
      expect(Entity::Search).to receive(:search).and_return([])
      expect(entity_match.instance_variable_get(:@name)).to eql 'test name'
      expect(entity_match.instance_variable_get(:@cmpid)).to eql '123'
      expect(entity_match.instance_variable_get(:@search_options))
        .to eql(:with => { primary_ext: "'Person'", is_deleted: false })
    end

    context 'with no search results' do
      before { expect(Entity::Search).to receive(:search).and_return([]) }
      specify { expect(entity_match.empty?).to be true }
      specify { expect(entity_match.has_match?).to be false }
      specify { expect(entity_match.count).to eql 0 }
      specify { expect(entity_match.first).to be nil }
      specify { expect(entity_match.second).to be nil }
    end

    context 'with one search results' do
      let(:person) { build(:person) }
      before { expect(Entity::Search).to receive(:search).and_return(Array.wrap(person)) }
      specify { expect(entity_match.empty?).to be false }
      specify { expect(entity_match.has_match?).to be true }
      specify { expect(entity_match.count).to eql 1 }
      specify { expect(entity_match.match).to eql person }
      specify { expect(entity_match.first).to eql person }
      specify { expect(entity_match.second).to be nil }
    end

    context 'with one search results AND a mach in the file' do
      let(:entity_match) { Cmp::EntityMatch.new(name: 'test name', primary_ext: 'Org', cmpid: '2400012') }
      let(:org) { build(:org) }
      let(:file_match) { build(:org, name: "McGill University") }
      before do
        allow(Entity::Search).to receive(:search).and_return(Array.wrap(org))
        allow(Entity).to receive(:find).with(15062).and_return(file_match)
      end
      specify { expect(entity_match.empty?).to be false }
      specify { expect(entity_match.has_match?).to be true }
      specify { expect(entity_match.count).to eql 1 }
      specify { expect(entity_match.match).to eql file_match }
      specify { expect(entity_match.first).to eql org }
      specify { expect(entity_match.second).to be nil }
    end

    context 'with three search results' do
      let(:people) { Array.new(3) { build(:person) } }
      before { expect(Entity::Search).to receive(:search).and_return(people) }
      specify { expect(entity_match.empty?).to be false }
      specify { expect(entity_match.count).to eql 3 }
      specify { expect(entity_match.first).to eql people[0] }
      specify { expect(entity_match.second).to be people[1] }
    end

  end
end
