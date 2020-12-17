describe Referenceable, type: :model do
  let(:test_referenceable_class) do
    Class.new(RspecHelpers::TestActiveRecord) do
      include ActiveModel::Validations
      include Referenceable

      def references; end

      def persisted?
        true
      end
    end
  end

  let(:io) { File.open(Rails.root.join('spec/testdata/example.png')) }

  describe 'validate_reference' do
    let(:referenceable) { test_referenceable_class.new }

    it 'invalidates the model if the reference is blank' do
      referenceable.validate_reference(url: '', name: 'blank url')
      expect(referenceable.valid?).to be false
      expect(referenceable.errors[:base]).to include 'A source URL is required'
    end

    it 'invalidates the model if the reference is not a valid url' do
      referenceable.validate_reference('url' => 'this is a bad url', 'name' => 'bad url')
      expect(referenceable.valid?).to be false
      expect(referenceable.errors[:base]).to include '"this is a bad url" is not a valid url'
    end

    it 'invalidates the model if the document name is too long' do
      referenceable.validate_reference(url: Faker::Internet.url, name: ('X' * 256))
      expect(referenceable.valid?).to be false
      expect(referenceable.errors[:base]).to include "Name is too long (maximum is 255 characters)"
    end

    it 'rereverts the invalidation if called again with valid attributes' do
      referenceable.validate_reference(url: '', name: 'blank url')
      expect(referenceable.valid?).to be false
      referenceable.validate_reference(url: Faker::Internet.url, name: 'good url')
      expect(referenceable.valid?).to be true
    end

    it 'does NOT invalidate the model if the reference has a valid url and valid name' do
      referenceable.validate_reference(url: Faker::Internet.url, name: 'good url')
      expect(referenceable.valid?).to be true
    end

    it 'does NOT invalidate the model if the reference has a valid url and empty name' do
      referenceable.validate_reference(url: Faker::Internet.url)
      expect(referenceable.valid?).to be true
    end

    it 'does NOT invalidate the model when a file is included' do
      referenceable.validate_reference(name: 'foobar', primary_source_document: io)
      expect(referenceable.valid?).to be true
    end
  end

  describe 'add_reference' do
    let(:url) { Faker::Internet.unique.url }
    let(:entity_person) { create(:entity_person) }

    it 'raises error if not persisted' do
      expect { Entity.new.add_reference(url: 'https://example.com') }.to raise_error(ActiveRecord::RecordNotSaved)
    end

    it 'raises error if url is invalid' do
      expect { entity_person.add_reference(url: 'bad_url') }.to raise_error(Document::DocumentAttributes::InvalidDocumentError)
    end

    it 'creates new reference' do
      expect { entity_person.add_reference(url: url) }.to change(Reference, :count).by(1)
    end

    it 'skips creating duplicates' do
      expect { 2.times { entity_person.add_reference(url: url) } }.to change(Reference, :count).by(1)
    end

    it 'creates new document' do
      expect { entity_person.add_reference(url: url) }.to change(Document, :count).by(1)
    end

    it 'uses existing document' do
      Document.find_or_create!(url: url, name: 'test_url')
      expect { entity_person.add_reference(url: url) }.not_to change(Document, :count)
    end

    it 'sets last_reference' do
      expect(entity_person.last_reference).to be nil
      entity_person.add_reference(url: url)
      expect(entity_person.last_reference).to be_a Reference
    end
  end

  # What should we do in this situation?
  # context 'existing Document, with different name'
  # end

  describe 'documents count' do
    it 'calls documents.count for referenceables' do
      list = build(:list)
      documents_double = double('documents')
      expect(documents_double).to receive(:count).once
      expect(list).to receive(:documents).and_return(documents_double)
      list.documents_count
    end
  end

  describe 'all_documents' do
    let(:entity) { build(:org) }
    let(:list) { build(:list) }

    it 'uses the regular pagination (.page) methods for other models' do
      mock_documents = spy('documents')
      expect(mock_documents).to receive(:page).with(1)
                                  .and_return(double(:per => nil))

      expect(list).to receive(:documents).and_return(mock_documents)

      list.all_documents(1)
    end
  end
end
