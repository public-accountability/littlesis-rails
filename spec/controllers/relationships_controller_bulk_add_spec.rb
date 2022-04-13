# frozen_string_literal: true

describe RelationshipsController, type: :controller do
  describe 'post bulk_add' do

    describe 'login user with importer permission' do
      login_user :collaborator

      let(:url) { Faker::Internet.unique.url }

      it 'sends error message if given bad reference' do
        params = { 'relationships' => [{ 'name' => 123 }], 'category_id' => 1, 'reference' => { 'url' => '', 'name' => 'important source' } }
        post :bulk_add!, params: params
        expect(response.status).to eq 400
      end

      describe 'submitting two good relationships' do
        let(:e1) { create(:entity_org) }
        let(:e2) { create(:entity_org) }

        let(:relationship1) do
          { 'name' => 'jane doe',
            'blurb' =>  nil,
            'primary_ext' => 'Person',
            'amount' => 500,
            'currency' => 'usd',
            'description1' => 'contribution',
            'start_date' => '2017-01-01',
            'end_date' => nil,
            'is_current' => nil }
        end

        let(:relationship2) do
          { 'name' => e2.id,
            'blurb' =>  nil,
            'primary_ext' => 'Org',
            'amount' =>  1000,
            'currency' => 'usd',
            'description1' => 'contribution',
            'start_date' => nil,
            'end_date' => nil,
            'is_current' => nil }
        end

        let(:params) do
          { 'entity1_id' => e1.id,
            'category_id' => 5,
            'reference' => { 'url' => url, 'name' => 'example.com' },
            'relationships' => [relationship1, relationship2] }
        end

        before { e1; e2; }

        it 'should return status 200' do
          post :bulk_add!, params: params
          expect(response.status).to eq 200
        end

        # one entity is new, one isn't
        it 'creates one new entity' do
          expect { post :bulk_add!, params: params }.to change(Entity, :count).by(1)
        end

        it 'creates two relationsips' do
          expect { post :bulk_add!, params: params }.to change(Relationship, :count).by(2)
        end

        it 'creates two donations' do
          expect { post :bulk_add!, params: params }.to change(Donation, :count).by(2)
        end

        it 'creates 5 References - 2 for relationships, 3 for associated entities ' do
          expect { post :bulk_add!, params: params }.to change(Reference, :count).by(5)
          expect(Reference.last(2).map(&:document).map(&:url)).to eq [url] * 2
        end

        it 'creates one Document' do
          expect { post :bulk_add!, params: params }.to change(Document, :count).by(1)
        end
      end

      describe 'submitting Relationship with category field' do
        let(:entity) { create(:entity_org) }

        let(:relationship1) do
          { 'name' => 'Jane Doe',
            'blurb' => nil,
            'primary_ext' => 'Person',
            'description1' => 'board member',
            'start_date' => '2017-01-01',
            'is_board' => true,
            'end_date' => nil,
            'is_current' => '?' }
        end

        let(:params) do
          { 'entity1_id' => entity.id,
            'category_id' => 1,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship1] }
        end

        it 'creates one relationship' do
          expect { post :bulk_add!, params: params }.to change(Relationship, :count).by(1)
        end

        it 'creates one Position' do
          expect { post :bulk_add!, params: params }.to change(Position, :count).by(1)
          expect(Position.last.relationship.entity2_id).to eql entity.id
        end

        it 'updates position' do
          post :bulk_add!, params: params
          expect(Position.last.is_board).to be true
        end
      end

      describe 'Submitting Relationship with Notes' do
        let(:entity) { create(:entity_org) }
        let(:notes_text) { "Important Notes" }

        let(:relationship1) do
          { 'name' => 'Jane Doe',
            'blurb' => nil,
            'primary_ext' => 'Person',
            'description1' => 'board member',
            'start_date' => '2017-01-01',
            'is_board' => true,
            'end_date' => nil,
            'notes' => notes_text,
            'is_current' => '?' }
        end

        let(:params) do
          { 'entity1_id' => entity.id,
            'category_id' => 1,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship1] }
        end

        it 'creates one relationship with notes' do
          expect { post :bulk_add!, params: params }.to change(Relationship, :count).by(1)
          expect(Relationship.last.notes).to eq notes_text
        end

      end

      context 'with bad relationship data' do
        let(:entity) { create(:entity_org) }

        let(:relationship) do
          { 'name' => 'Jane Doe',
            'blurb' => nil,
            'primary_ext' => 'Person',
            'description1' => 'board member',
            'start_date' => 'this is not a real date' }
        end

        let(:params) do
          { 'entity1_id' => entity.id,
            'category_id' => 12,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship] }
        end

        let(:bulk_add_request) do
          lambda { post :bulk_add!, params: params }
        end

        specify do
          expect(&bulk_add_request).not_to change(Relationship, :count)
        end

        it 'responds with 200' do
          bulk_add_request.call
          expect(response.status).to eq 200
          expect(JSON.parse(response.body)['errors'].length).to eq 1
        end
      end

      describe 'one good relationsihp json and one bad realtionship json' do
        # subject { lambda { post :bulk_add!, params: params } }

        let(:relationship1) do
          { 'name' => 'jane doe',
            'blurb' =>  nil,
            'primary_ext' => 'Person',
            'start_date' => '2017-01-01',
            'end_date' => nil,
            'is_current' => nil }
        end

        let(:relationship2) do
          { 'name' => 'evil corp',
            'blurb' => nil,
            'primary_ext' => 'Org',
            'start_date' => 'this is not a real date',
            'end_date' => nil,
            'is_current' => nil }
        end

        let(:params) do
          { 'entity1_id' => create(:entity_org).id,
            'category_id' => 12,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship1, relationship2] }
        end

        specify do
          expect { post :bulk_add!, params: params }.to change(Relationship, :count).by(1)
        end

        it 'responds with 200' do
          post :bulk_add!, params: params
          expect(response.status).to eq 200
        end
      end

      describe 'When submitting position relationships' do
        let(:corp) { create(:entity_org) }
        let(:person) { create(:entity_person) }
        let(:relationship_params) do
          { 'name' => person.id, 'primary_ext' => 'Person', 'start_date' => '2017-01-01' }
        end

        let(:params) do
          { 'entity1_id' => corp.id,
            'category_id' => 1,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship_params] }
        end

        specify do
          expect { post :bulk_add!, params: params }.to change(Relationship, :count).by(1)
        end

        it 'reverses entity id correctly' do
          post :bulk_add!, params: params
          rel = Relationship.last
          expect(rel.category_id).to eq 1
          expect(rel.entity.primary_ext).to eql 'Person'
          expect(rel.related.primary_ext).to eql 'Org'
        end
      end

      describe 'submitting an education relationship (reversed)' do
        let(:school) { create(:entity_org) }
        let(:student) { create(:entity_person) }

        let(:params) do
          { 'entity1_id' => school.id,
            'category_id' => Relationship::EDUCATION_CATEGORY,
            'reference' => { 'url' => "https://example.com", 'name' => 'example.com' },
            'relationships' => [ {
                                   'name' => student.id,
                                   'blurb' => nil,
                                   'primary_ext' => 'Person',
                                   'description1' => nil,
                                   'start_date' => nil,
                                   'end_date' => nil,
                                   'degree' => nil,
                                   'field' => 'math',
                                   'is_dropout' => nil
                                 } ] }
        end

        let(:bulk_request) do
          lambda { post :bulk_add!, params: params }
        end

        it 'creates a new relationship' do
          expect(&bulk_request).to change(Relationship, :count).by(1)
        end

        it 'reverses entity1 and entity2' do
          bulk_request.call
          expect(Relationship.last.attributes.slice('entity1_id', 'entity2_id'))
                   .to eq('entity1_id' => student.id, 'entity2_id' => school.id)
        end
      end

      describe 'When submitting a donation relationship' do
        let(:relationships) do
          [
            { 'name' => 'small donor', 'primary_ext' => 'Person', 'amount' => '$1,000' },
            { 'name' => 'medium donor', 'primary_ext' => 'Person', 'amount' => '$100000.50' },
            { 'name' => 'big donor', 'primary_ext' => 'Person', 'amount' => '1,000,000' },
            { 'name' => 'reallybig donor', 'primary_ext' => 'Person', 'amount' => '100000000' }
          ]
        end

        let(:corp) { create(:entity_org) }

        let(:params) do
          { 'entity1_id' => corp.id,
            'category_id' => 5,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => relationships }
        end

        before { params }

        it 'creates 4 relationships' do
          expect { post :bulk_add!, params: params }.to change(Relationship, :count).by(4)
          expect(Entity.find(corp.id).relationships.count).to eq 4
        end

        it 'converts amount field' do
          post :bulk_add!, params: params
          amounts = Entity.find(corp.id).relationships.map(&:amount)
          expect(amounts).to include 1000
          expect(amounts).to include 100_000
          expect(amounts).to include 1_000_000
          expect(amounts).to include 100_000_000
        end
      end

      describe 'handling donation currencies' do
        let(:corp) { create(:entity_org) }
        let(:reference) { { url: 'http://example.com', name: 'example.com' } }
        let(:relationships) do
          [
            { name: '$ donor', primary_ext: 'Person', amount: '$1,000', currency: :usd },
            { name: '€ donor', primary_ext: 'Person', amount: '10000', currency: :eur },
            { name: 'blank currency donor', primary_ext: 'Person', amount: '€1,000', currency: '' },
            { name: 'nonsense currency donor', primary_ext: 'Person', amount: '€1,000', currency: 'cigarettes' }
          ]
        end
        let!(:params) { { entity1_id: corp.id, category_id: 5, reference: reference, relationships: relationships } }

        before do
          post :bulk_add!, params: params
        end

        it 'returns currency errors' do
          json = JSON.parse(response.body)
          expect(json['errors'].count).to be 1
          expect(json['errors'].first['errorMessage']).to include('cigarettes is not a valid currency')
        end

        it 'creates relationships with valid currencies' do
          currencies = Entity.find(corp.id).relationships.map(&:currency)
          expect(currencies.count).to be 3
          expect(currencies).to include('usd', 'eur')
          expect(currencies).not_to include('', 'cigarettes')
        end
      end

      context 'When submitting a Donation Received or Doantion Given relationship' do
        let(:corp) { create(:entity_org) }

        let(:relationship)  do
          { 'name' => 'donor guy', 'primary_ext' => 'Person', 'amount' => '$20' }
        end

        let(:params) do
          { 'entity1_id' => corp.id,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship] }
        end

        let(:donation_received) { params.merge('category_id' => 50) }
        let(:donation_given) { params.merge('category_id' => 51) }

        it 'creates one donation received relationship' do
          expect { post :bulk_add!, params: donation_received }.to change(Relationship, :count).by(1)
        end

        it 'changes entity order for donation received' do
          post :bulk_add!, params: donation_received
          expect(Relationship.last.entity2_id).to eq corp.id
        end

        it 'creates one donation given relationship' do
          expect { post :bulk_add!, params: donation_given }.to change(Relationship, :count).by(1)
        end

        it 'does not change entity order for donation given' do
          post :bulk_add!, params: donation_given
          expect(Relationship.last.entity1_id).to eq corp.id
        end
      end

      context 'when submitting a membership (30) relationship' do
        let(:person) { create(:entity_person) }
        let(:relationship) do
          { 'name' => 'some membership org', 'primary_ext' => 'Org' }
        end

        let(:params) do
          { 'entity1_id' => person.id,
            'category_id' => 30,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship] }
        end

        it 'creates one relationship' do
          expect { post :bulk_add!, params: params }.to change(Relationship, :count).by(1)
        end

        it 'sets correct entity id order' do
          post :bulk_add!, params: params
          expect(Relationship.last.entity1_id).to eq person.id
        end
      end

      context 'when submitting a members (31) relationship' do
        let(:org) { create(:entity_org) }
        let(:relationship) { { 'name' => 'some membership org', 'primary_ext' => 'Org' } }

        let(:params) do
          { 'entity1_id' => org.id,
            'category_id' => 31,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship] }
        end

        it 'creates one relationship' do
          expect { post :bulk_add!, params: params }.to change(Relationship, :count).by(1)
        end

        it 'sets correct entity id order' do
          post :bulk_add!, params: params
          expect(Relationship.last.entity2_id).to eq org.id
        end
      end

      context 'when submitting an invalid members (31) relationship' do
        let(:person) { create(:entity_person) }
        let(:relationship) { { 'name' => 'some membership org', 'primary_ext' => 'Org' } }

        let(:params) do
          { 'entity1_id' => person.id,
            'category_id' => 31,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship] }
        end

        it 'does not creates one relationship' do
          expect { post :bulk_add!, params: params }.not_to change(Relationship, :count)
        end
      end

      describe 'it will rollback entity transaction if an ActiveRecord Error occur' do
        let(:generic_relationship) do
          { 'name' => 'new entity',
            'blurb' =>  nil,
            'primary_ext' => 'Org',
            'amount' =>  nil,
            'description1' => 'd1',
            'description2' => 'd2',
            'start_date' => nil,
            'end_date' => 'THE END!', # <---- bad date
            'is_current' => nil }
        end

        let(:corp) { create(:entity_org) }

        let(:params) do
          { 'entity1_id' => corp.id,
            'category_id' => 12,
            'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [generic_relationship] }
        end

        before { corp }

        specify do
          expect { post :bulk_add!, params: params }.not_to change(Relationship, :count)
        end

        specify do
          expect { post :bulk_add!, params: params }.not_to change(Entity, :count)
        end
      end
    end
  end

  describe 'Permissions' do
    let(:relationship) do
      { 'name' => 'jane doe',
        'blurb' =>  nil,
        'primary_ext' => 'Person',
        'start_date' => '2017-01-01',
        'end_date' => nil,
        'is_current' => nil }
    end

    let(:params) do
      { 'entity1_id' => create(:entity_org).id,
        'category_id' => 12,
        'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
        'relationships' => [relationship] }
    end

    let(:ten_relationships_params) do
      { 'entity1_id' => 1,
        'category_id' => 5,
        'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
        'relationships' => [{ 'relationship' => 'details' }] * 10 }
    end

    context 'user not logged in' do
      it 'returns 302' do
        post :bulk_add!, params: ten_relationships_params
        expect(response).to have_http_status :found
      end
    end

    context 'user with regular permissions' do
      login_user :editor

      it 'allows submission of one relationship' do
        post :bulk_add!, params: params
        json = JSON.parse(response.body)
        expect(response).to have_http_status 200
        expect(json['errors'].length).to eq 0
        expect(json['relationships'].length).to eq 1
      end

      it 'does not allow submission of ten relationships' do
        post :bulk_add!, params: ten_relationships_params
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'user with bulk permissions' do
      login_user :collaborator

      it 'allows submission of 10 relationships' do
        expect(Entity).to receive(:find).and_return(build(:org))
        expect(controller).to receive(:make_or_get_entity).exactly(10).times
        post :bulk_add!, params: ten_relationships_params
        expect(response).to have_http_status 200
      end
    end
  end

  describe 'make_or_get_entity' do
    login_user
    let(:relationship) { { 'name' => 'new person', 'blurb' => 'words', 'primary_ext' => 'Person', 'is_board' => true } }
    let(:relationship_with_invalid_id) { { 'name' => '987654321', 'blurb' => 'blurb', 'primary_ext' => 'Person' } }
    let(:relationship_existing) { { 'name' => '666', 'blurb' => '', 'primary_ext' => 'Person' } }
    let(:relationship_error) { { 'name' => 'i am a cat', 'blurb' => 'meow', 'primary_ext' => nil } }

    specify { expect { |b| controller.send(:make_or_get_entity, relationship, &b) }.to yield_with_args(Entity) }

    def set_errors
      controller.instance_variable_set(:@errors, [])
    end

    it 'creates new entity' do
      expect { controller.send(:make_or_get_entity, relationship) {} }.to change(Entity, :count).by(1)
    end

    it' finds existing entity' do
      expect(Entity).to receive(:find_by).with(id: 666).and_return(create(:entity_person))
      controller.send(:make_or_get_entity, relationship_existing) {}
    end

    context 'with bad data' do
      before { set_errors }

      specify { expect { |b| controller.send(:make_or_get_entity, relationship_error, &b) }.not_to yield_control }

      it 'increases error array' do
        expect { controller.send(:make_or_get_entity, relationship_error) }
          .to change { controller.instance_variable_get(:@errors).length }.by(1)
      end
    end

    context 'with entity id that does not exist' do
      before { set_errors }

      specify { expect { |b| controller.send(:make_or_get_entity, relationship_with_invalid_id, &b) }.not_to yield_control }

      it 'increases error count' do
        expect { controller.send(:make_or_get_entity, relationship_error) }
          .to change { controller.instance_variable_get(:@errors).length }.by(1)
      end
    end
  end
end
