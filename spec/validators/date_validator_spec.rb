describe 'DateValidator' do
  class DateTester <
        include ActiveModel::Validations
    attr_accessor :start_date
    validates :start_date, date: true
  end

  subject { DateTester.new }

  context 'When the date is valid' do
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
  end

  context 'When the date is invalid' do
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
  end
end
