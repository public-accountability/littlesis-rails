describe 'Relationships Requests' do
  let(:user) { create_editor }
  let(:person) { create(:entity_person, :with_person_name) }
  let(:org) { create(:entity_org, :with_org_name) }

  before { login_as(user, :scope => :user) }

  after { logout(:user) }

  describe 'Creating Relationships' do
    let(:params) do
      {
        relationship: {
          entity1_id: person.id,
          entity2_id: org.id,
          category_id: 1,
          is_current: 'YES',
          description1: 'Director'
        },
        reference: attributes_for(:document)
      }
    end

    let(:request) { -> { post relationships_path, params: params } }

    context 'when position relationship recived' do
      specify do
        expect(&request).to change(Relationship, :count).by(1)
      end

      specify do
        expect(&request).to change(Reference, :count).by(3)
      end

      specify do
        expect(&request).to change { person.reload.last_user_id }.to(user.id)
      end

      specify do
        expect(&request).to change { org.reload.last_user_id }.to(user.id)
      end

      it 'responds with json containing the relationship id' do
        request.call
        relationship = Relationship.last
        expect(json).to eq("path" => "/relationships/#{relationship.id}",
                           "relationship_id" => relationship.id,
                           "url"=> "http://test.host/relationships/#{relationship.id}")
      end

      context 'with board membership relationships' do
        before do
          params[:relationship][:position_attributes] = { is_board: 'true' }
        end

        specify do
          expect(&request).to change(Relationship, :count).by(1)
        end

        it 'corrects updates "is_board" on position' do
          expect(&request).to change(Position, :count).by(1)
          expect(Position.last.is_board).to be true
        end
      end

      context 'when is_board is marked as "no"' do
        before do
          params[:relationship][:position_attributes] = { is_board: 'no' }
        end

        specify do
          expect(&request).to change(Relationship, :count).by(1)
        end

        it 'corrects updates "is_board" on position' do
          expect(&request).to change(Position, :count).by(1)
          expect(Position.last.is_board).to be false
        end
      end
    end

    context 'with invalid url' do
      before { params[:reference][:url] = 'I AM A BAD URL' }

      specify do
        expect(&request).not_to change(Relationship, :count)
      end

      it 'rends json of errors' do
        request.call
        expect(response).to have_http_status :bad_request
        expect(response.body).to include 'is not a valid url'
      end
    end

    context 'with amount field but no currency' do
      before { params[:relationship][:amount] = '$25,000' }

      it 'adds USD amount to relationship' do
        expect(&request).to change(Relationship, :count).by(1)
        expect(Relationship.last.amount).to eq 25_000
        expect(Relationship.last.currency).to eq 'usd'
      end
    end

    context 'with amount and currency' do
      before { params[:relationship].merge!(amount: '13000', currency: 'eur') }

      it 'adds currency and amount to relationship' do
        expect(&request).to change(Relationship, :count).by(1)
        expect(Relationship.last.amount).to eq 13_000
        expect(Relationship.last.currency).to eq 'eur'
      end
    end

    context 'with currency but no amount' do
      before { params[:relationship].merge!(amount: nil, currency: 'aud') }

      it 'raises validation error' do
        expect(&request).not_to change(Relationship, :count)
        expect(response).to have_http_status :bad_request
        expect(response.body).to include 'entered without an amount'
      end
    end
  end

  describe 'Updating relationships' do
    let(:notes) { Faker::Lorem.sentence }

    describe 'Position Relationship' do
      let(:position_relationship) do
        Relationship
          .create!(category_id: 1, entity: person, related: org, description1: 'Lobbyist')
          .tap { |r| r.position.update_columns(is_executive: true) }
      end

      let(:base_params) do
        {
          reference: { just_cleaning_up: 1, url: nil, name: nil },
          relationship: {
            description1: 'Lobbyist',
            start_date: '2009',
            end_date: nil,
            is_current: nil,
            notes: notes,
            position_attributes: {
              is_board: 'true',
              is_executive: 'true',
              is_employee: nil,
              compensation: nil,
              id: position_relationship.position.id
            }
          }
        }
      end
      let(:params) { base_params }
      let(:patch_request) { proc { patch relationship_path(position_relationship), params: params } }

      describe 'updating relationship fields' do
        it 'redirects to relationship page' do
          patch_request.call
          redirects_to_path relationship_path(position_relationship)
        end

        it 'updates relationship fields and position fields' do
          expect(position_relationship.start_date).to be_nil
          expect(position_relationship.notes).to be_nil
          expect(position_relationship.position.is_board).to be_nil
          expect(position_relationship.position.is_executive).to be true
          patch_request.call
          position_relationship.reload
          expect(position_relationship.start_date).to eql '2009-00-00'
          expect(position_relationship.position.is_board).to be true
          expect(position_relationship.position.is_executive).to be true
          expect(position_relationship.notes).to eql notes
          expect(position_relationship.entity1_id).to eql person.id
        end
      end

      context 'when an invalid date is submitted' do
        let(:params) { base_params.deep_merge(relationship: { start_date: 'BAD DATE' }) }

        before { patch_request.call }

        renders_the_edit_page

        it 'rejects changes to the relationship' do
          expect(position_relationship.reload.start_date).to be_nil
          expect(position_relationship.reload.notes).to be_nil
        end
      end
    end # Position Relationship

    describe 'Transaction Relationship' do
      let(:entity1) { create(:entity_org, :with_org_name) }
      let(:entity2) { create(:entity_org, :with_org_name) }

      let(:transaction_relationship) do
        Relationship.create!(category_id: Relationship::TRANSACTION_CATEGORY,
                             entity: entity1,
                             related: entity2,
                             description1: 'Contractor',
                             description2: 'Client')
      end

      let(:base_params) do
        {
          reference: { just_cleaning_up: 1, url: nil, name: nil },
          relationship: {
            description1: 'Contractor',
            description2: 'Client',
            start_date: '',
            end_date: '',
            is_current: '',
            notes: '',
            trans_attributes: { is_lobbying: 'true' }
          }
        }
      end

      let(:params) { base_params }
      let(:patch_request) { proc { patch relationship_path(transaction_relationship), params: params } }

      def self.updates_transaction_fields
        it 'upates relationship and transaction fields' do
          expect(transaction_relationship.trans.is_lobbying).to be_nil
          patch_request.call
          transaction_relationship.reload
          redirects_to_path relationship_path(transaction_relationship)
          expect(transaction_relationship.trans.is_lobbying).to be true
        end
      end

      context 'updating without reversing' do
        let(:params) { base_params.deep_merge(reverse_direction: 'false') }

        updates_transaction_fields

        it 'does not reverse the relationship' do
          patch_request.call
          transaction_relationship.reload
          expect(transaction_relationship.trans.is_lobbying).to be true
          expect(transaction_relationship.entity1_id).to eql entity1.id
          expect(transaction_relationship.entity2_id).to eql entity2.id
        end
      end

      context 'updating AND reversing' do
        let(:params) { base_params.deep_merge(reverse_direction: 'true') }

        updates_transaction_fields

        it 'reverses the relationship' do
          patch_request.call
          transaction_relationship.reload
          expect(transaction_relationship.trans.is_lobbying).to be true
          expect(transaction_relationship.entity1_id).to eql entity2.id
          expect(transaction_relationship.entity2_id).to eql entity1.id
        end
      end
    end # end updating and reversing
  end # end updating relationships

  describe 'deleting relationship' do
    with_versioning do
      let!(:relationship) do
        PaperTrail.request(whodunnit: user.id.to_s) do
          create(:generic_relationship, entity: create(:entity_person), related: create(:entity_person))
        end
      end

      context 'when requesting as the editor who created' do
        it 'deletes relationship and redirects to dashboard' do
          delete relationship_path(relationship)
          expect(relationship.reload.is_deleted).to be true
          expect(response).to have_http_status(:found)
          expect(response.location).to include '/home/dashboard'
        end

        it 'cannot be deleted when older than one week' do
          relationship.update_columns(created_at: 1.month.ago)
          delete relationship_path(relationship)
          expect(relationship.reload.is_deleted).to be false
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe 'bulk adding relationships' do
    it 'sends error message if given bad reference' do
      params = { 'relationships' => [{ 'name' => 123 }], 'category_id' => 1, 'reference' => { 'url' => '', 'name' => 'important source' } }
      post "/relationships/bulk_add", params: params
      expect(response.status).to eq 400
    end

    describe 'submitting two good relationships' do
      let(:e1) { create(:entity_org) }
      let(:e2) { create(:entity_org) }
      let(:url) { Faker::Internet.unique.url }

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

      it 'creates relationships and responds with ok' do
        relationship_count = Relationship.count
        post '/relationships/bulk_add', params: params
        expect(response).to have_http_status(:ok)
        expect(Relationship.count).to eq(relationship_count + 2)
      end

      it 'creates 5 References - 2 for relationships, 3 for associated entities' do
        document_count = Document.count
        expect { post '/relationships/bulk_add', params: params }.to change(Reference, :count).by(5)
        expect(Reference.last(2).map(&:document).map(&:url)).to eq [url] * 2
        expect(Document.count).to eq (document_count + 1)
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
        expect { post '/relationships/bulk_add', params: params }.to change(Relationship, :count).by(1)
      end

      it 'creates one Position' do
        expect { post '/relationships/bulk_add', params: params }.to change(Position, :count).by(1)
        expect(Position.last.relationship.entity2_id).to eql entity.id
        expect(Position.last.is_board).to be true
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

      it 'reverses entity1 and entity2' do
        post '/relationships/bulk_add', params: params
        expect(Relationship.last.attributes.slice('entity1_id', 'entity2_id'))
          .to eq('entity1_id' => student.id, 'entity2_id' => school.id)
      end
    end

    describe 'submitting a membership (30) relationship' do
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

      it 'sets correct entity id order' do
        expect { post '/relationships/bulk_add', params: params }.to change(Relationship, :count).by(1)
        expect(Relationship.last.entity1_id).to eq person.id
      end
    end

    describe 'it rollbacks transaction with created entity when ActiveRecord Error occurs' do
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
        expect { post '/relationships/bulk_add', params: params }.not_to change(Relationship, :count)
      end

      specify do
        expect { post '/relationships/bulk_add', params: params }.not_to change(Entity, :count)
      end
    end

    describe 'submitting one valid and one invalid realtionship' do
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
        expect { post '/relationships/bulk_add', params: params }.to change(Relationship, :count).by(1)
        expect(response).to have_http_status(:ok)
        expect(json['errors'].length).to eq 1
        expect(json['errors'][0]['errorMessage']).to match(/invalid date/)
        expect(json['relationships'].length).to eq 1
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

      let!(:params) do
        { 'entity1_id' => corp.id,
          'category_id' => 5,
          'reference' => { 'url' => 'http://example.com', 'name' => 'example.com' },
          'relationships' => relationships }
      end

      it 'creates 4 relationships with correct amount fields' do
        expect { post '/relationships/bulk_add', params: params }.to change(Relationship, :count).by(4)
        corp.reload
        expect(corp.relationships.count).to eq 4
        amounts = corp.relationships.map(&:amount).to_set
        expect(amounts).to eq [1000, 100_000, 1_000_000, 100_000_000].to_set
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
        post '/relationships/bulk_add', params: params
      end

      it 'returns currency errors' do
        json = JSON.parse(response.body)
        expect(json['errors'].count).to be 1
        expect(json['errors'].first['errorMessage']).to include('cigarettes is not a valid currency')
        currencies = corp.reload.relationships.map(&:currency)
        expect(currencies.count).to be 3
        expect(currencies).to include('usd', 'eur')
        expect(currencies).not_to include('', 'cigarettes')
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

      context 'when user not logged in' do
        before { logout(:user) }

        it 'returns 302' do
          post '/relationships/bulk_add', params: ten_relationships_params
          expect(response.location).to include '/login'
          expect(response).to have_http_status :found
        end
      end

      describe 'user with regular permissions' do
        it 'allows submission of one relationship' do
          post '/relationships/bulk_add', params: params
          json = JSON.parse(response.body)
          expect(response).to have_http_status 200
          expect(json['errors'].length).to eq 0
          expect(json['relationships'].length).to eq 1
        end

        it 'does not allow submission of ten relationships' do
          post '/relationships/bulk_add', params: ten_relationships_params
          expect(response).to have_http_status :unauthorized
        end
      end
    end
  end # end bulk adding relationships
end
