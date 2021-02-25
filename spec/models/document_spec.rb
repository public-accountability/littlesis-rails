describe Document, type: :model do
  let(:url) { Faker::Internet.unique.url }

  let(:io) do
    File.open(Rails.root.join('spec/testdata/example.png'))
  end

  describe 'validations' do
    subject(:document) { Document.new(url: url, name: 'a website') }

    it { is_expected.to have_many(:references) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }

    it 'checks uniqueness of url_hash' do
      document.save!
      new_doc_with_same_url = Document.new(url: url)
      expect(new_doc_with_same_url.valid?).to be false
      expect(new_doc_with_same_url.errors[:url_hash]).to eql ['has already been taken']
    end

    it 'checks the validitity of urls' do
      expect(Document.new(url: url).valid?).to be true
      expect(Document.new(url: 'not-a-complete-url.com').valid?).to be false
    end

    it 'validates primary_source_document' do
      d = Document.new(name: 'example.png', ref_type: 'primary_source')
      expect(d.valid?).to be false
      d.primary_source_document.attach(io: io, filename: 'example.png')
      expect(d.valid?).to be true
    end

    describe 'before validation callbacks: trims whitespace and creates url hash' do
      let(:document) { Document.new(url: '   https://littlesis.org  ', name: '  LittleSis  ') }

      before { document.valid? }

      specify { expect(document.url).to eql 'https://littlesis.org' }
      specify { expect(document.name).to eql 'LittleSis' }
      specify { expect(document.url_hash).to eql Digest::SHA1.hexdigest('https://littlesis.org') }
    end

    it 'converts blank string publication dates into nil' do
      document = build(:document, url: url, publication_date: '')
      expect(document.valid?).to be true
    end

    it 'uses LsDate to handle varations on publication date' do
      document = build(:document, url: url, publication_date: '1999')
      expect(document.valid?).to be true
      expect(document.publication_date).to eql '1999-00-00'
    end
  end

  describe 'find_by_url' do
    let!(:document) { create(:document, url: url) }

    it 'find urls by using the hash' do
      expect(Document.find_by_url(url)).to eq document
    end

    it 'returns nil for urls that do not yet exist' do
      expect(Document.find_by_url("#{url}/different_page")).to be nil
    end

    it 'raises error if blank values are submitted' do
      expect { Document.find_by_url(nil) }.to raise_error(Exceptions::InvalidUrlError)
      expect { Document.find_by_url("") }.to raise_error(Exceptions::InvalidUrlError)
    end

    it 'raises error if invalid urls are are submitted' do
      expect { Document.find_by_url('website.com') }.to raise_error(Exceptions::InvalidUrlError)
      expect { Document.find_by_url('i am not a url') }.to raise_error(Exceptions::InvalidUrlError)
    end
  end

  describe 'recording history with paper trail' do
    with_versioning do
      it 'does not record create events' do
        expect { create(:document) }.not_to change { PaperTrail::Version.count }
      end

      it 'records update events' do
        d = create(:document)
        expect(d.versions.count).to eq 0
        d.update!(name: Faker::Creature::Cat.registry)
        expect(d.versions.count).to eq 1
      end
    end
  end

  describe 'Saving to internet archive' do
    let(:document) { build(:document) }

    it 'enqueues jobs after creating a new document' do
      expect { document.save! }.to have_enqueued_job.with(document.url)
    end
  end

  describe Document::DocumentAttributes do
    specify do
      dattrs = Document::DocumentAttributes.new({'url' => 'https://example.com', 'name' => 'example website'})
      expect(dattrs.url).to eq 'https://example.com'
      expect(dattrs.name).to eq 'example website'
      expect(dattrs.valid?).to be true
      expect(dattrs.error_message).to be nil
      expect(dattrs.to_h).to eq ({ name: 'example website', url: 'https://example.com' }).with_indifferent_access
    end

    specify do
      dattrs = Document::DocumentAttributes.new(url: 'https://example.com')
      expect(dattrs.url).to eq 'https://example.com'
      expect(dattrs.name).to eq 'https://example.com'
      expect(dattrs.valid?).to be true
    end

    specify do
      invalid_url = Document::DocumentAttributes.new(url: 'file:///important')
      expect(invalid_url.valid?).to be false
      expect(invalid_url.error_message).to eq '"file:///important" is not a valid url'
    end

    specify do
      expect(Document::DocumentAttributes.new(url: 'file:///important').valid?).to be false
      long_name = Document::DocumentAttributes.new(url: 'https://littlesis.org', name: ('x' * 256))
      expect(long_name.valid?).to be false
      expect(long_name.error_message).to eq 'Name is too long (maximum is 255 characters)'
    end

    specify do
      expect(Document.valid_url?('https://mēx.example')).to be true
    end
  end
end
