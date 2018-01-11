require "rails_helper"

RSpec.describe Cmp do

  describe Cmp::CmpEntity do
    let(:attrs) { { :name => Faker::Cat.name } }
    subject { Cmp::CmpEntity.new attrs }
    specify { expect(subject.attributes).to eql attrs }
  end

  describe Cmp::ExcelSheet do

    class TestCmpExcelSheet < Cmp::ExcelSheet
      HEADER_MAP = { cmpid: 'CMPID_ORGL', cmpname: 'CMPName' }
    end
    
    let(:excel_file_path) { Rails.root.join('spec', 'testdata', 'cmp_orgs.xlsx').to_s } 
      
    subject { TestCmpExcelSheet.new(excel_file_path) }

    it 'parses excel sheet into an array of hash according to the header converstion map' do
      expect(subject.to_a).to eql([
                                    { cmpid: 5100178, cmpname: 'BNP PARIBAS' },
                                    { cmpid: 5100179, cmpname: 'TELEFONICA SA' } ])
    end
  end
end
