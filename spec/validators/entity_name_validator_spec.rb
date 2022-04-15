describe 'EntityNameValidator' do
  class NameTester <
    include ActiveModel::Validations
    attr_accessor :name
    attr_accessor :primary_ext
    validates :name, entity_name: true
  end

  subject { NameTester.new }

  describe 'Valid names' do
    before do
      subject.primary_ext = 'Person'
    end

    it 'sally valid is valid' do
      subject.name = 'sally valid'
      expect(subject.valid?).to be true
    end

    it 'Joe McValid Jr. is valid' do
      subject.name = 'Joe McValid Jr.'
      expect(subject.valid?).to be true
    end
  end

  describe 'InValid names' do
    before { subject.primary_ext = 'Person' }

    it 'sally is invalid' do
      subject.name = 'sally'
      expect(subject.valid?).to be false
    end

    it '!!! is invalid' do
      subject.name = '!!!'
      expect(subject.valid?).to be false
    end

    it ' "" is invalid' do
      subject.name = ''
      expect(subject.valid?).to be false
    end
  end

  describe 'Org' do
    before { subject.primary_ext = 'Org' }

    it 'name is valid' do
      subject.name = 'name'
      expect(subject.valid?).to be true
    end

    it 'corp llc is valid' do
      subject.name = 'corp llc'
      expect(subject.valid?).to be true
    end

    it 'ab is invalid' do
      subject.name = 'ab'
      expect(subject.valid?).to be false
    end
  end
end
