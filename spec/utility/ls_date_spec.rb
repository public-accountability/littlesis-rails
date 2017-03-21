require 'rails_helper'

describe LsDate do
  describe 'initalize' do
    describe 'test_if_valid_input' do 
      it 'raises error if provided invalid date string' do
        expect { LsDate.new('1922') }.to raise_error ArgumentError
        expect { LsDate.new('2000-12') }.to raise_error ArgumentError
      end

      it 'allows valid date' do
        expect { LsDate.new('1900-12-08') }.not_to raise_error
      end

      it 'allows nil to be a valid date' do
        expect { LsDate.new(nil) }.not_to raise_error
      end
    end

    it 'sets date string' do
      d = LsDate.new('1999-01-01')
      expect(d.date_string).to eql '1999-01-01'
    end

    describe 'set_year_month day' do
      it 'sets @year, @month, and @day for full date' do
        d = LsDate.new('2001-02-14')
        expect(d.year).to eql 2001
        expect(d.month).to eql 2
        expect(d.day).to eql 14
      end

      it 'sets @year, @month, and @day when missing day' do
        d = LsDate.new('2001-02-00')
        expect(d.year).to eql 2001
        expect(d.month).to eql 2
        expect(d.day).to eql nil
      end

      it 'sets @year, @month, and @day when missing day and month' do
        d = LsDate.new('2001-00-00')
        expect(d.year).to eql 2001
        expect(d.month).to eql nil
        expect(d.day).to eql nil
      end
    end    
    
    describe 'specificity' do
      it 'has correct specificity :day when full date' do
        expect(LsDate.new('2017-01-01').specificity).to eql :day
      end

      it 'has correct specificity :month when missing day' do
        expect(LsDate.new('2017-01-00').specificity).to eql :month
      end

      it 'has correct specificity :year when missing day and month' do
        expect(LsDate.new('2017-00-00').specificity).to eql :year
      end

      it 'has correct specificity :unknown when missing day, month, and year' do
        expect(LsDate.new(nil).specificity).to eql :unknown
      end
    end
    
  end

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
