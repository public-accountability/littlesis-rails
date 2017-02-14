require 'rails_helper'

describe LsDate do
  describe 'convert' do
    it 'converts YYYY to YYYY-00-OO' do
      expect(LsDate.convert('2019')).to eql '2019-00-00'
    end

    it 'converts YYYY-MM to YYYY-MM-OO' do
      expect(LsDate.convert('2019-12')).to eql '2019-12-00'
    end

    it 'converts YYYYMMDD to YYYY-MM-OO' do
      expect(LsDate.convert('20011231')).to eql '2001-12-31'
    end

    it 'returns input if it can\'t convert' do
      expect(LsDate.convert('88')).to eql '88'
      expect(LsDate.convert('1234567')).to eql '1234567'
      expect(LsDate.convert('2000-04-01')).to eql '2000-04-01'
      expect(LsDate.convert(nil)).to be nil
      expect(LsDate.convert('right now')).to eql 'right now'
    end
  end
end
