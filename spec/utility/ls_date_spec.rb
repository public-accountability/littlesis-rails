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
    end  end

  describe 'Comparisons' do
    it 'returns equal when both are unknown' do
      expect( LsDate.new(nil) == LsDate.new(nil)).to be true
    end
    
    it 'a defined date is greater than an unknown date' do
      expect( LsDate.new('1799-00-00') > LsDate.new(nil)).to be true
      expect( LsDate.new('1799-01-00') > LsDate.new(nil)).to be true
      expect( LsDate.new('1799-01-31') > LsDate.new(nil)).to be true
      expect( LsDate.new(nil) < LsDate.new('1799-00-00')).to be true 
    end

    it 'works when years are different' do
      expect( LsDate.new('1799-00-00') > LsDate.new('1600-00-00')).to be true
      expect( LsDate.new('2017-00-00') > LsDate.new('2016-10-28')).to be true
      expect( LsDate.new('2017-10-00') > LsDate.new('2016-10-00')).to be true
      expect( LsDate.new('2000-00-00') < LsDate.new('2016-10-28')).to be true
    end

    context 'years are the same' do
      it 'if month is defined, the more specific date wins' do
        expect( LsDate.new('2017-00-00') < LsDate.new('2017-03-00')).to be true
        expect( LsDate.new('2017-00-00') < LsDate.new('2017-01-01')).to be true
      end
      
      it 'if only year is defined, then they are equal' do
        expect( LsDate.new('2017-00-00') == LsDate.new('2017-00-00')).to be true
      end
    end
    
    it 'works when years is the same, but the months are different' do
      expect( LsDate.new('2017-02-00') < LsDate.new('2017-03-00')).to be true
      expect( LsDate.new('2017-10-00') < LsDate.new('2017-11-00')).to be true
    end

    it 'is equal when year and month are the same and both are missing days' do 
      expect( LsDate.new('2017-02-00') == LsDate.new('2017-02-00')).to be true
    end

    it 'works when year and month are the same and one is missing a day' do 
      expect( LsDate.new('2017-02-27') > LsDate.new('2017-02-00')).to be true
    end
  end

  describe 'display' do
    it 'displays unknown as ?' do
      expect( LsDate.new(nil).display).to eql '?'
    end

    it "displays :year as 'YY" do
      expect( LsDate.new('1926-00-00').display).to eql "'26"
    end

    it "displays :month as 'Mon 'YY" do
      expect( LsDate.new('1926-11-00').display).to eql "Nov '26"
    end

    it "displays :year as 'Mon DD, 'YY" do
      expect( LsDate.new('2008-02-24').display).to eql "Feb 24 '08"
    end
  end
end
