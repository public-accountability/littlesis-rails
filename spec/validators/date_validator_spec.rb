# frozen_string_literal: true

# rubocop:disable RSpec/NamedSubject

describe 'DateValidator' do
  class DateTester <
        include ActiveModel::Validations
    attr_accessor :start_date, :end_date
    validates :start_date, date: true
    validates :end_date, date: true
  end

  subject { DateTester.new }

  context 'when the date is valid' do
    it 'nil is valid' do
      subject.start_date = nil
      expect(subject.valid?).to be true
    end

    it '2012-00-00 is valid' do
      subject.start_date = '2012-00-00'
      expect(subject.valid?).to be true
    end

    it '2012-02-00 is valid' do
      subject.start_date = '2012-02-00'
      expect(subject.valid?).to be true
    end

    it '1999-05-10 is valid' do
      subject.start_date = '1999-05-10'
      expect(subject.valid?).to be true
    end

    it '2016-08-11 is valid' do
      subject.start_date = '2016-08-11'
      expect(subject.valid?).to be true
    end

    it 'May 1st, 1970 is valid' do
      subject.start_date = 'May 1st, 1970'
      expect(subject.valid?).to be true
    end

    it 'April 4, 2000 is valid' do
      subject.start_date = 'April 4, 2000'
      expect(subject.valid?).to be true
    end

    it 'Jan 5th 2010' do
      subject.start_date = 'Jan 5th 2010'
      expect(subject.valid?).to be true
    end
  end

  context 'when the date is invalid' do
    it '2012 is not valid' do
      subject.start_date = '2012'
      expect(subject.valid?).to be false
    end

    it '2012-10 is not valid' do
      subject.start_date = '2012-10'
      expect(subject.valid?).to be false
    end

    it '2012-13-01 is not valid' do
      subject.start_date = '2012-13-01'
      expect(subject.valid?).to be false
    end

    it '01/20/2017 is not valid' do
      subject.start_date = '01/20/2017'
      expect(subject.valid?).to be false
    end

    it 'Today is not valid' do
      subject.start_date = 'Today'
      expect(subject.valid?).to be false
    end

    it '1234567891 is not valid' do
      subject.start_date = '1234567891'
      expect(subject.valid?).to be false
    end

    it 'Gin 1 werp is not valid' do
      subject.start_date = 'Gin 1 werp'
      expect(subject.valid?).to be false
    end

    it 'XXXX-XX-XX is not valid' do
      subject.start_date = 'XXXX-XX-XX'
      expect(subject.valid?).to be false
    end
  end

  describe 'validates chronology of start and end dates' do
    it 'rejects when end_date is before start date' do
      subject.start_date = '1990-01-01'
      subject.end_date = '1980-01-01'
      expect(subject.valid?).to be false
    end

    it 'rejects when start_date is after end date' do
      subject.end_date = '2000-01-01'
      expect(subject.valid?).to be true
      subject.start_date = '2000-01-02'
      expect(subject.valid?).to be false
    end

    it 'is okay if start and end date and are the same' do
      subject.start_date = '1990-01-01'
      subject.end_date = '1990-01-01'
      expect(subject.valid?).to be true
    end
  end
end

# rubocop:enable RSpec/NamedSubject
