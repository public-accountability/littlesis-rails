# rubocop:disable Rails/DynamicFindBy

describe Document, :pagination_helper, type: :model do
  let(:url) { Faker::Internet.unique.url }

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

  describe 'documents_for_entity' do
    let(:entity) { create(:entity_org) }
    let(:relationships) do
      Array.new(3) { create(:generic_relationship, entity: entity, related: create(:entity_person)) }
    end
    let(:url) { Faker::Internet.unique.url }

    let(:fec_document) do
      create(:fec_document)
    end

    # create a reference the entity and each relationship
    # the first relationship references to the same
    # document as the entity's refernce
    # documents_for_entity should return only 3 documents
    let(:add_3_documents) do
      proc {
        entity.add_reference(url: url, name: 'a url')
        # give the first relationship a reference with the same url as the entity
        relationships.first.add_reference(url: url, name: 'a url')
        relationships.second.add_reference(attributes_for(:document))
        relationships.third.references.create!(document_id: fec_document.id)
      }
    end

    context 'when retriving page 1' do
      before do
        create(:document) # create a random document unrelated to this query
        add_3_documents.call
        relationships.third.references.first.update_column(:updated_at, 10.minutes.from_now)
      end

      subject(:document) { Document.documents_for_entity(entity: entity, page: 1) }

      it 'returns 3 documents' do
        expect(document.length).to eq 3
      end

      it 'sorts by updated at date' do
        expect(document.first).to eq fec_document
      end

      describe 'excluding documents by type' do
        it 'can exclude fec documents (using a symbol)' do
          expect(Document.documents_for_entity(entity: entity, page: 1, exclude_type: :fec).length).to eq 2
        end

        it 'can exclude fec documents (using an integer)' do
          expect(Document.documents_for_entity(entity: entity, page: 1, exclude_type: 2).length).to eq 2
        end

        it 'raises error if given a incorrect ref type' do
          expect do
            Document.documents_for_entity(entity: entity, page: 1, exclude_type: 1000)
          end.to raise_error(ArgumentError)
        end
      end
    end

    describe 'pagination' do
      stub_page_limit Document, limit: 2

      before do
        3.times { entity.add_reference(attributes_for(:document)) }
      end

      it 'page one contains 2 documents' do
        expect(Document.documents_for_entity(entity: entity, page: 1).length).to eq 2
      end

      it 'page two contains 1 documents' do
        expect(Document.documents_for_entity(entity: entity, page: 2).length).to eq 1
        expect(Document.documents_for_entity(entity: entity, page: 1).map(&:url).to_set)
          .not_to include Document.documents_for_entity(entity: entity, page: 2).first.url
      end
    end

    describe 'retriving documents for multiple entities at once' do
      # add a second entity, a relationship, and a reference + document for each
      # the query for both should return 5
      let(:second_entity) { create(:entity_person) }
      let(:second_entity_relationship) do
        Relationship.create!(category_id: 1, entity: second_entity, related: create(:entity_org))
      end

      before do
        create(:document) # create a random document unrelated to this query
        add_3_documents.call # add 3 documents for the first entity
        # add two for the second:
        second_entity.add_reference(attributes_for(:document))
        second_entity_relationship.add_reference(attributes_for(:document))
      end

      it 'returns 5 documents' do
        expect(Document.documents_for_entity(entity: [entity.id, second_entity.id], page: 1).length)
          .to eq 5
      end
    end
  end

  describe 'documents_count_for_entity' do
    let(:entity) { create(:entity_org) }
    let(:other_entity) { create(:entity_person) }
    let(:relationship) do
      create(:generic_relationship, entity: entity, related: other_entity)
    end

    # create 3 documents and references for the entity
    before do
      2.times { entity.add_reference(attributes_for(:document)) }
      relationship.add_reference(attributes_for(:document))
      other_entity.add_reference(attributes_for(:document))
    end

    specify do
      expect(Document.documents_count_for_entity(entity)).to eq 3
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
  end
end

# rubocop:enable Rails/DynamicFindBy
