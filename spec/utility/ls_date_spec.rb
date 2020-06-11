# rubocop:disable Lint/UselessComparison, RSpec/Multipleexpectations

describe LsDate do
  describe 'initialize' do
    describe 'test_if_valid_input' do
      it 'raises error if provided invalid date string' do
        expect { LsDate.new('1922') }.to raise_error LsDate::InvalidLsDateError
        expect { LsDate.new('2000-12') }.to raise_error LsDate::InvalidLsDateError
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

  describe 'LsDate.parse and parse!' do
    specify { expect(LsDate.parse('2012')).to be_a LsDate }
    specify { expect(LsDate.parse('2012').to_s).to eq '2012-00-00' }
    specify { expect(LsDate.parse!('2012').to_s).to eq '2012-00-00' }
    specify { expect(LsDate.parse(nil)).to eq LsDate.new(nil) }
    specify { expect(LsDate.parse('invalid')).to eq LsDate.new(nil) }

    specify do
      expect { LsDate.parse!('invalid') }.to raise_error(LsDate::InvalidLsDateError)
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

    it 'converts blank strings to nil' do
      expect(LsDate.convert('')).to eql nil
    end

    it 'converts MM/YYYY' do
      expect(LsDate.convert('04/2015')).to eq '2015-04-00'
      expect(LsDate.convert('12/1960')).to eq '1960-12-00'
      expect(LsDate.convert('12/2007')).to eq '2007-12-00'
    end

    it 'converts MON-YY (Dec-07)' do
      expect(LsDate.convert('Dec-07')).to eq '2007-12-00'
      expect(LsDate.convert('Feb-18')).to eq '2018-02-00'
    end

    # '12/2007'
    # ''Dec-07'

    it 'returns input if it can\'t convert' do
      expect(LsDate.convert('88')).to eql '88'
      expect(LsDate.convert('1234567')).to eql '1234567'
      expect(LsDate.convert('2000-04-01')).to eql '2000-04-01'
      expect(LsDate.convert(nil)).to be nil
      expect(LsDate.convert('right now')).to eql 'right now'
      expect(LsDate.convert('13/2000')).to eql '13/2000'
    end
  end

  describe 'parse_cmp_date' do
    it 'handles nil and blank strings' do
      expect(LsDate.parse_cmp_date(nil)).to be nil
      expect(LsDate.parse_cmp_date('')).to be nil
    end

    it 'handles years' do
      expect(LsDate.parse_cmp_date('1960').to_s).to eql '1960-00-00'
    end

    it 'handles months' do
      expect(LsDate.parse_cmp_date('04/1970').to_s).to eql '1970-04-00'
    end

    it 'handles full dates' do
      expect(LsDate.parse_cmp_date('22/04/1970').to_s).to eql '1970-04-22'
    end

    it 'returns nil for invalid dates' do
      expect(LsDate.parse_cmp_date('25/1980')).to be nil
      expect(LsDate.parse_cmp_date('7/980')).to be nil
    end
  end

  describe 'Comparisons' do
    it 'returns equal when both are unknown' do
      expect(LsDate.new(nil) == LsDate.new(nil)).to be true
    end

    it 'a defined date is greater than an unknown date' do
      expect(LsDate.new('1799-00-00') > LsDate.new(nil)).to be true
      expect(LsDate.new('1799-01-00') > LsDate.new(nil)).to be true
      expect(LsDate.new('1799-01-31') > LsDate.new(nil)).to be true
      expect(LsDate.new(nil) < LsDate.new('1799-00-00')).to be true
    end

    it 'works when years are different' do
      expect(LsDate.new('1799-00-00') > LsDate.new('1600-00-00')).to be true
      expect(LsDate.new('2017-00-00') > LsDate.new('2016-10-28')).to be true
      expect(LsDate.new('2017-10-00') > LsDate.new('2016-10-00')).to be true
      expect(LsDate.new('2000-00-00') < LsDate.new('2016-10-28')).to be true
    end

    context 'years are the same' do
      it 'if month is defined, the more specific date wins' do
        expect(LsDate.new('2017-00-00') < LsDate.new('2017-03-00')).to be true
        expect(LsDate.new('2017-00-00') < LsDate.new('2017-01-01')).to be true
      end

      it 'if only year is defined, then they are equal' do
        expect(LsDate.new('2017-00-00') == LsDate.new('2017-00-00')).to be true
      end
    end

    it 'works when years is the same, but the months are different' do
      expect(LsDate.new('2017-02-00') < LsDate.new('2017-03-00')).to be true
      expect(LsDate.new('2017-10-00') < LsDate.new('2017-11-00')).to be true
    end

    it 'is equal when year and month are the same and both are missing days' do
      expect(LsDate.new('2017-02-00') == LsDate.new('2017-02-00')).to be true
    end

    it 'works when year and month are the same and one is missing a day' do
      expect(LsDate.new('2017-02-27') > LsDate.new('2017-02-00')).to be true
    end
  end

  describe 'display' do
    it 'displays unknown as ?' do
      expect(LsDate.new(nil).display).to eql '?'
    end

    it "displays :year as 'YY" do
      expect(LsDate.new('1926-00-00').display).to eql "'26"
    end

    it "displays :month as 'Mon 'YY" do
      expect(LsDate.new('1926-11-00').display).to eql "Nov '26"
    end

    it "displays :year as 'Mon DD, 'YY" do
      expect(LsDate.new('2008-02-24').display).to eql "Feb 24 '08"
    end
  end

  describe 'to_date' do
    it 'returns nil' do
      expect(LsDate.new(nil).to_date).to be nil
    end

    it 'returns <Date>' do
      expect(LsDate.new('1915-02-08').to_date).to be_a Date
    end

    it 'raises error if date cannot be parsed' do
      expect { LsDate.new('1915-00-00').to_date }.to raise_error(ArgumentError)
      expect { LsDate.new('1915-02-00').to_date }.to raise_error(ArgumentError)
    end
  end

  describe 'to_s' do
    specify { expect(LsDate.new('2018-10-10').to_s).to eql '2018-10-10' }
  end

  describe 'valid_date_string?' do
    it 'valid dates' do
      ['2012-01-01', '2012-01-00', '2012-00-00'].each do |d|
        expect(LsDate.valid_date_string?(d)).to be true
      end
    end

    it 'invalid dates' do
      ['Ginuary sometime', '1000', 'today'].each do |d|
        expect(LsDate.valid_date_string?(d)).to be false
      end
    end
  end

  describe 'coerce_to_date' do
    it 'returns nil' do
      expect(LsDate.new(nil).coerce_to_date).to be nil
    end

    it 'returns <Date>' do
      expect(LsDate.new('1915-02-08').coerce_to_date).to be_a Date
    end

    it 'returns valid dates even if month or day is unknown' do
      expect(LsDate.new('1915-00-00').coerce_to_date).to eql Date.parse('1915-01-01')
      expect(LsDate.new('1915-02-00').coerce_to_date).to eql Date.parse('1915-02-01')
    end
  end

  describe 'LsDate.today' do
    specify do
      expect(LsDate.today.to_s).to eq Time.zone.today.iso8601
    end
  end

  describe 'handling arbitrary date formats' do
    let(:same_date) { described_class.new('2010-06-01') }
    let(:previous_date) { described_class.new('2009-05-01') }
    let(:future_date) { described_class.new('2020-08-12') }

    context 'with 1st June 2010' do
      let(:input_string) { '1st June 2010' }
      let(:date) { described_class.new(input_string) }

      it "doesn't raise an exception" do
        expect { date }.not_to raise_error
      end

      it 'is considered valid' do
        expect(described_class.valid_date_string?(input_string)).to be true
      end

      it 'performs correctly in spaceship comparisons' do
        expect(date.<=> same_date).to be(0)
        expect(date.<=> previous_date).to be(1)
        expect(date.<=> future_date).to be(-1)
      end

      it 'is parsed correctly into component elements' do
        expect(date.year).to be 2010
        expect(date.month).to be 6
        expect(date.day).to be 1
      end
    end

    context 'with 1 June, 2010' do
      let(:input_string) { '1 June, 2010' }
      let(:date) { described_class.new(input_string) }

      it "doesn't raise an exception" do
        expect { date }.not_to raise_error
      end

      it 'is considered valid' do
        expect(described_class.valid_date_string?(input_string)).to be true
      end

      it 'performs correctly in spaceship comparisons' do
        expect(date.<=> same_date).to be(0)
        expect(date.<=> previous_date).to be(1)
        expect(date.<=> future_date).to be(-1)
      end

      it 'is parsed correctly into component elements' do
        expect(date.year).to be 2010
        expect(date.month).to be 6
        expect(date.day).to be 1
      end
    end

    context 'with June 1, 2010' do
      let(:input_string) { 'June 1, 2010' }
      let(:date) { described_class.new(input_string) }

      it "doesn't raise an exception" do
        expect { date }.not_to raise_error
      end

      it 'is considered valid' do
        expect(described_class.valid_date_string?(input_string)).to be true
      end

      it 'performs correctly in spaceship comparisons' do
        expect(date.<=> same_date).to be(0)
        expect(date.<=> previous_date).to be(1)
        expect(date.<=> future_date).to be(-1)
      end

      it 'is parsed correctly into component elements' do
        expect(date.year).to be 2010
        expect(date.month).to be 6
        expect(date.day).to be 1
      end
    end

    context 'with June 1 2010' do
      let(:input_string) { 'June 1 2010' }
      let(:date) { described_class.new(input_string) }

      it "doesn't raise an exception" do
        expect { date }.not_to raise_error
      end

      it 'is considered valid' do
        expect(described_class.valid_date_string?(input_string)).to be true
      end

      it 'performs correctly in spaceship comparisons' do
        expect(date.<=> same_date).to be(0)
        expect(date.<=> previous_date).to be(1)
        expect(date.<=> future_date).to be(-1)
      end

      it 'is parsed correctly into component elements' do
        expect(date.year).to be 2010
        expect(date.month).to be 6
        expect(date.day).to be 1
      end
    end
  end
end
# rubocop:enable Lint/UselessComparison, RSpec/Multipleexpectations
