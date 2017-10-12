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
  end

  describe 'before validation callbacks: trims whitespace and creates url hash' do
    let(:subject) { Document.new(url: '   https://littlesis.org  ', name: '  LittleSis  ') }
    before { subject.valid? }
    specify { expect(subject.url).to eql 'https://littlesis.org' }
    specify { expect(subject.name).to eql 'LittleSis' }
    specify { expect(subject.url_hash).to eql Digest::SHA1.hexdigest('https://littlesis.org') }
  end
end
