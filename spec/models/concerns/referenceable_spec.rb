describe Referenceable, type: :model do
  class TestReferenceable < TestActiveRecord
    include ActiveModel::Validations
    include Referenceable

    def references; end

    def persisted?
      true
    end
  end

  describe 'validate_reference' do
    let(:referenceable) { TestReferenceable.new }

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
      expect(referenceable.errors[:base]).to include "name is too long (maximum is 255 characters)"
    end

    it 'rereverts the invalidation if called again with valid attributes' do
      referenceable.validate_reference(url: '', name: 'blank url')
      expect(referenceable.valid?).to be false
      referenceable.validate_reference(url: Faker::Internet.url, name: 'good url')
      expect(referenceable.valid?).to be true
    end

    it 'does NOT invalidate the model if the refrence has a valid url and valid name' do
      referenceable.validate_reference(url: Faker::Internet.url, name: 'good url')
      expect(referenceable.valid?).to be true
    end

    it 'does NOT invalidate the model if the refrence has a valid url and empty name' do
      referenceable.validate_reference(url: Faker::Internet.url)
      expect(referenceable.valid?).to be true
    end
  end

  describe 'add_reference' do
    let(:referenceable) { TestReferenceable.new }
    let(:url) { Faker::Internet.unique.url }
    let(:url_name) { Faker::Lorem.sentence }
    let(:attributes) { { url: url, name: url_name } }
    let(:add_reference) { proc { referenceable.add_reference(attributes) } }

    def creates_new_reference
      expect(referenceable).to receive(:references)
                                 .twice.and_return(double(:create => nil, :exists? => false))
    end

    def does_not_create_new_reference
      expect(referenceable).to receive(:references).once
                                 .and_return(double(:exists? => true))
    end

    it 'throws if called on a record that has not yet been saved' do
      expect(referenceable).to receive(:persisted?).and_return(false)
      expect { add_reference.call }.to raise_error(ActiveRecord::RecordNotSaved)
    end

    context 'submitted with invalid url' do
      let(:url) { 'not-a-url' }

      it 'does not create a new document' do
        expect { add_reference.call }.not_to change { Document.count }
      end

      it 'adds an error to the record' do
        expect(referenceable.valid?).to be true
        add_reference.call
        expect(referenceable.valid?).to be false
        expect(referenceable.errors[:base].first).to eql '"not-a-url" is not a valid url'
      end
    end

    context 'no existing Document or Reference' do
      it 'creates a new document' do
        creates_new_reference
        expect { add_reference.call }.to change { Document.count }.by(1)
      end

      it 'creates a new reference' do
        creates_new_reference
        add_reference.call
      end

      it 'returns self' do
        creates_new_reference
        expect(add_reference.call).to eql referenceable
      end
    end

    context 'existing Document, but no existing Reference' do
      before { Document.create!(url: url, name: url_name) }

      it 'does not create a new document' do
        creates_new_reference
        expect { add_reference.call }.not_to change { Document.count }
      end

      it 'creates a new reference' do
        creates_new_reference
        add_reference.call
      end
    end

    context 'existing Document and Reference' do
      before { Document.create!(url: url, name: url_name) }

      it 'does not create a new document or reference' do
        does_not_create_new_reference
        expect { add_reference.call }.not_to change { Document.count }
      end
    end

    context 'with no URL when references are optional' do
      let(:referenceable) { TestReferenceable.new }
      let(:url) { '' }

      before do
        referenceable.class.define_singleton_method(:reference_optional?) do
          true
        end
      end

      it 'does not create a new document' do
        expect { add_reference.call }.not_to change(Document, :count)
      end

      it 'does not add an error to the record' do
        add_reference.call
        expect(referenceable.valid?).to be true
      end
    end

    # What should we do in this situation?
    context 'existing Document, with different name'
  end

  describe 'add_reference_by_document_id' do
    let(:referenceable) { TestReferenceable.new }

    it 'raises error if document does not exist' do
      expect(Document).to receive(:find_by_id).with('123').and_return(nil)
      expect { referenceable.add_reference_by_document_id('123') }
        .to raise_error(ArgumentError)
    end

    it 'adds new reference' do
      references_double = double("references")
      expect(Document).to receive(:find_by_id).with('123').and_return(build(:document))
      expect(references_double).to receive(:create).with(document_id: '123')
      expect(referenceable).to receive(:references).and_return(double(:exists? => false))
      expect(referenceable).to receive(:references).and_return(references_double)
      referenceable.add_reference_by_document_id('123')
    end
  end

  describe 'documents count' do
    context 'if an entity' do
      it 'uses Document.documents_count_for_entity' do
        entity = build(:org)
        expect(Document).to receive(:documents_count_for_entity).once.with(entity)
        entity.documents_count
      end
    end

    context 'if any referenceable besides entity' do
      it 'uses documents.count' do
        list = build(:list)
        documents_double = double('documents')
        expect(documents_double).to receive(:count).once
        expect(list).to receive(:documents).and_return(documents_double)
        list.documents_count
      end
    end
  end

  describe 'all_documents' do
    let(:entity) { build(:org) }
    let(:list) { build(:list) }

    context 'if an entity' do
      it 'uses Document.documents_for_entity' do
        expect(Document).to receive(:documents_for_entity)
                              .with(entity: entity, page: 1, per_page: 20)
                              .and_return([build(:document)])

        expect(Document).to receive(:documents_count_for_entity)
                              .with(entity).and_return(1)

        all_documents = entity.all_documents(1)
        expect(all_documents).to be_a Kaminari::PaginatableArray
      end
    end

    context 'if a list' do
      it 'uses the regular pagination (.page) methods' do
        mock_documents = spy('documents')
        expect(mock_documents).to receive(:page).with(1)
                                    .and_return(double(:per => nil))

        expect(list).to receive(:documents)
                          .and_return(mock_documents)

        list.all_documents(1)
      end
    end
  end
end
