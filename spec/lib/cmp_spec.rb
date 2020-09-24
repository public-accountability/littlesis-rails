require 'cmp'

describe Cmp do
  describe Cmp::CmpEntityImporter do
    let(:attrs) { LsHash.new(name: Faker::Creature::Cat.name, cmpid: Faker::Number.number(digits: 6)) }
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
    it 'EntityMatch.matches return hash of all manual matches' do
      expect(Cmp::EntityMatch.matches).to be_a Hash
      expect(Cmp::EntityMatch::MATCHES.length).to be > 25
    end
  end
end
