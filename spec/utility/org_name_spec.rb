require 'rails_helper'

describe OrgName do
  describe 'parse'

  describe 'strip_name_punctuation' do
    it 'removes commas and period' do
      expect(OrgName.strip_name_punctuation('TAKEDA PHARMACEUTICAL CO., LTD.'))
        .to eql 'TAKEDA PHARMACEUTICAL CO LTD'
    end

    it 'keeps periods if part of an url' do
      expect(OrgName.strip_name_punctuation('corp.com')).to eql 'corp.com'
    end

    it 'removes double-quotes' do
      expect(OrgName.strip_name_punctuation('US "BANK"')).to eql 'US BANK'
    end

    it 'replaces double spaces with single spaces' do
      expect(OrgName.strip_name_punctuation('XYZ  INC')).to eql 'XYZ INC'
    end
  end
end
