require 'rails_helper'

describe Document, type: :model do
  describe 'validations' do
    let(:url) { Faker::Internet.unique.url }
    subject { Document.new(url: url, name: 'a website') }

    it { should have_many(:references) }
    it { should validate_presence_of(:url) }
    it { should validate_length_of(:name).is_at_most(255) }

    it 'checks uniqueness of url_hash' do
      subject.save!
      new_doc_with_same_url = Document.new(url: url)
      expect(new_doc_with_same_url.valid?).to be false
      expect(new_doc_with_same_url.errors[:url_hash]).to eql ['has already been taken']
    end

    describe 'before validation callbacks: trims whitespace and creates url hash' do
      let(:subject) { Document.new(url: '   https://littlesis.org  ', name: '  LittleSis  ') }
      before { subject.valid? }
      specify { expect(subject.url).to eql 'https://littlesis.org' }
      specify { expect(subject.name).to eql 'LittleSis' }
      specify { expect(subject.url_hash).to eql Digest::SHA1.hexdigest('https://littlesis.org') }
    end
  end

  describe 'ref types' do
    it 'has REF_TYPES constant' do
      expect(Document::REF_TYPES).to be_a Hash
    end

    it '#ref_types_display returns display text of the document\'s ref type' do
      expect(build(:document, ref_type: 1).ref_types_display).to eql 'Generic'
      expect(build(:document, ref_type: 3).ref_types_display).to eql 'Newspaper'
      expect(build(:document, ref_type: nil).ref_types_display).to be nil
    end

    describe 'ref_type_options' do
      subject { Document.ref_type_options }
      it { is_expected.to eql [['Generic', 1], ['Newspaper', 3], ['Government Document', 4]] }
    end
  end
end
