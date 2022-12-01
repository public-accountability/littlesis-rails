describe RelationshipsController, type: :controller do
  let(:user) { create_basic_user }
  let(:e1) { create(:entity_person, last_user_id: user.id, created_at: 1.day.ago, updated_at: 1.day.ago) }
  let(:e2) { create(:entity_org, last_user_id: user.id, created_at: 1.day.ago, updated_at: 1.day.ago) }

  it { is_expected.to route(:get, '/relationships/1').to(action: :show, id: 1) }
  it { is_expected.to route(:post, '/relationships').to(action: :create) }
  it { is_expected.to route(:get, '/relationships/1/edit').to(action: :edit, id: 1) }
  it { is_expected.to route(:post, '/relationships/1/reverse_direction').to(action: :reverse_direction, id: 1) }
  it { is_expected.to route(:patch, '/relationships/1').to(action: :update, id: 1) }
  it { is_expected.to route(:delete, '/relationships/1').to(action: :destroy, id: 1) }
  it { is_expected.to route(:get, '/relationships/bulk_add').to(action: :bulk_add) }
  it { is_expected.to route(:post, '/relationships/bulk_add').to(action: :bulk_add!) }
  it { is_expected.to route(:get, '/relationships/find_similar').to(action: :find_similar) }
  it { is_expected.to route(:post, '/relationships/1/tags').to(action: :tags, id: 1) }

  describe 'GET #show' do
    let(:rel) { build(:relationship) }

    before do
      allow(Relationship).to receive(:find).with('1').and_return(rel)
      get :show, params: { id: 1 }
    end

    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:show) }

    it 'assigns relationship' do
      expect(assigns(:relationship)).to eql rel
    end
  end

  describe 'POST #create' do
    login_admin

    def example_params(entity1_id = '10', entity2_id = '20')
      {
        relationship: {
          entity1_id: entity1_id,
          entity2_id: entity2_id,
          category_id: '1'
        },
        reference: {
          name: 'Interesting website',
          url: 'http://example.com',
        }
      }
    end

    context 'with valid params' do
      it 'responds with 201' do
        post :create, params: example_params(e1.id, e2.id)
        expect(response.status).to eq 201
      end

      it 'sends back json with relationship_id' do
        response = (post :create, params: example_params(e1.id, e2.id))
        json = JSON.parse(response.body)
        expect(json['relationship_id']).to eq(Relationship.last.id)
      end

      it 'creates a new relationship' do
        post_request = -> { post :create, params: example_params(e1.id, e2.id) }
        expect(&post_request).to change(Relationship, :count).by(1)
      end

      it 'creates 3 references' do
        post_request = -> { post :create, params: example_params(e1.id, e2.id) }
        expect(&post_request).to change(Reference, :count).by(3)
        Reference.last(3).map { |r| r.document.url }.each do |url|
          expect(url).to eq 'http://example.com'
        end
      end

      it 'creates or finds a document with the correct fields' do
        response = post(:create, params: example_params(e1.id, e2.id))
        json = JSON.parse(response.body)
        expect(Reference.last.document.name).to eq 'Interesting website'
      end

      it 'changes updated_at of entities' do
        e1.update_column(:updated_at, 1.day.ago)
        e2.update_column(:updated_at, 1.day.ago)
        post :create, params: example_params(e1.id, e2.id)
        expect(Entity.find(e1.id).updated_at).to be > 1.minute.ago
        expect(Entity.find(e2.id).updated_at).to be > 1.minute.ago
      end

      it 'updates last_user_id' do
        post :create, params: example_params(e1.id, e2.id)
        expect(Entity.find(e1.id).last_user_id).not_to eql user.id
        expect(Entity.find(e2.id).last_user_id).not_to eql user.id
      end
    end

    context 'with invalid params' do
      it 'responds with 400 if missing category_id' do
        post :create, params: example_params.tap { |x| x[:relationship].delete(:category_id) }
        expect(response.status).to eq 400
      end

      it 'sends error json with bad relationship params' do
        response = JSON.parse(
          post(:create, params: example_params.tap { |x| x[:relationship].delete(:category_id) }).body
        )
        expect(response).to have_key 'error'
        expect(response['error']).to include 'category_id'
      end

      it 'responds with 400 if missing reference url' do
        post :create, params: example_params(entity1_id: e1.id, entity2_id: e2.id)
                        .tap { |x| x[:reference].delete(:url) }
        expect(response.status).to eq 400
      end

      it 'sends error json with reference params' do
        response = post(:create, params: example_params(entity1_id: e1.id, entity2_id: e2.id)
                        .tap { |x| x[:reference].delete(:url) })
        expect(JSON.parse(response.body)).to have_key 'error'
      end
    end

    describe 'submitting with an existing document id' do
      let!(:document_id) do
        e1.add_reference(attributes_for(:document))
        e1.references.first.document_id
      end

      let(:params) do
        {
          relationship: {
            entity1_id: e1.id,
            entity2_id: e2.id,
            category_id: '1'
          },
          reference: {
            document_id: document_id
          }
        }
      end

      it 'creates a new reference, associated with the relationship' do
        expect { post :create, params: params }.to change(Reference, :count).by(1)
      end

      it 'does not create a document' do
        expect { post :create, params: params }.not_to change(Document, :count)
      end
    end

    describe 'submitting relationship with is_current values' do
      it '"yes" sets is_current' do
        expect do
          post :create, params: example_params(e1.id, e2.id).tap { |x| x[:relationship][:is_current] = 'YES' }
        end.to change(Relationship, :count).by(1)
        id_of_created_relationship = JSON.parse(response.body)['relationship_id']
        expect(Relationship.find(id_of_created_relationship).is_current).to eq true
      end

      it '"no" sets is_current to false' do
        expect do
          post :create, params: example_params(e1.id, e2.id).tap { |x| x[:relationship][:is_current] = 'NO' }
        end.to change(Relationship, :count).by(1)
        id_of_created_relationship = JSON.parse(response.body)['relationship_id']
        expect(Relationship.find(id_of_created_relationship).is_current).to eq false
      end

      it '"NULL" set is_current to nil' do
        expect do
          post :create, params: example_params(e1.id, e2.id).tap { |x| x[:relationship][:is_current] = 'NULL' }
        end.to change(Relationship, :count).by(1)
        id_of_created_relationship = JSON.parse(response.body)['relationship_id']
        expect(Relationship.find(id_of_created_relationship).is_current).to be nil
      end
    end
  end # end describe POST #create

  describe 'GET /relationships/id/edit' do
    login_user
    let(:relationship) { build :relationship }

    describe 'viewing the edit relationship page' do
      before do
        allow(Relationship).to receive(:find).with('1').and_return(build(:relationship))
        get :edit, params: { id: 1 }
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:edit) }
    end

    context 'when editing a reference directly after created it (new_ref = true)' do
      context 'when there is no reference' do
        before do
          expect(Relationship).to receive(:find).with('1').and_return(relationship)
          get :edit, params: { id: 1, new_ref: 'true' }
        end

        it { is_expected.to respond_with(:success) }
        it { is_expected.to render_template(:edit) }

        it 'sets @selected_ref to be nil' do
          expect(assigns(:selected_ref)).to be nil
        end
      end
    end
  end

  describe 'PATCH /relationships/id' do
    login_user

    context 'when updating start and end dates' do
      let!(:relationship) do
        create(:generic_relationship, entity: e1, related: e2, last_user_id: user.id)
      end

      before do
        e1.update_column(:updated_at, 1.day.ago)
        e2.update_column(:updated_at, 1.day.ago)
      end

      context 'when submitting an invalid date' do
        let(:params) do
          { id: relationship.id, relationship: {'start_date' => '012345678910' }, reference: { 'just_cleaning_up' => '1' } }
        end

        before { patch :update, params: params }

        it { is_expected.to respond_with(:success) }
        it { is_expected.to render_template(:edit) }

        it 'does not change the updated_at of entities' do
          expect(Entity.find(e1.id).updated_at).to be <= 1.hour.ago
          expect(Entity.find(e2.id).updated_at).to be <= 1.hour.ago
        end

        it 'does not update last_user_id' do
          expect(Entity.find(e1.id).last_user_id).to eql user.id
          expect(Entity.find(e2.id).last_user_id).to eql user.id
        end
      end

      context "when request is valid request" do
        let(:params) do
          { id: relationship.id,
            relationship: { 'start_date' => '2012-12-12' },
            reference: { 'reference_id' => '123' } }
        end

        before { patch :update, params: params }

        it { is_expected.to redirect_to(relationship_path) }

        it 'updates db' do
          expect(Relationship.find(relationship.id).start_date).to eql '2012-12-12'
        end

        it 'changes updated_at of entities' do
          expect(Entity.find(e1.id).updated_at).to be > 1.hour.ago
          expect(Entity.find(e2.id).updated_at).to be > 1.hour.ago
        end

        it 'updates last_user_id' do
          expect(Entity.find(e1.id).last_user_id).not_to eql user.id
          expect(Entity.find(e2.id).last_user_id).not_to eql user.id
        end
      end

      context 'with blank string as start and end date' do
        let(:params) do
          { id: relationship.id, relationship: { 'start_date' => '', 'end_date' => '' }, reference: { 'reference_id' => '123' } }
        end

        before { patch :update, params: params }

        it 'keeps start_date as nil' do
          expect(Relationship.find(relationship.id).start_date).to be nil
        end

        it 'keeps end_date as nil' do
          expect(Relationship.find(relationship.id).end_date).to be nil
        end
      end

      context 'with alternative date formats' do
        it 'allows date as YYYY' do
          patch :update,
                params: { id: relationship.id,
                          relationship: { 'start_date' => '2017' },
                          reference: { 'reference_id' => '123' } }
          expect(Relationship.find(relationship.id).start_date).to eql '2017-00-00'
        end

        it 'allows date as YYYY-MM' do
          patch :update,
                params: { id: relationship.id,
                          relationship: { 'end_date' => '2017-09' },
                          reference: { 'reference_id' => '123' } }
          expect(Relationship.find(relationship.id).end_date).to eql '2017-09-00'
        end

        it 'allows date as YYYYMMDD' do
          patch :update, params: { id: relationship.id,
                                   relationship: { 'end_date' => '20170925' },
                                   reference: { 'reference_id' => '123' } }
          expect(Relationship.find(relationship.id).end_date).to eql '2017-09-25'
        end
      end

      describe 'invalid reference' do
        let(:params) do
          { id: relationship.id,
            relationship: { 'start_date' => '2001-01-01' },
            reference: { 'url' => '', 'name' => '' } }
        end

        before { patch :update, params: params }

        it { is_expected.to render_template(:edit) }

        it 'does not update the relationship' do
          expect(Relationship.find(relationship.id).start_date).to be nil
        end
      end

      describe 'request with new reference' do
        let(:document_attributes) { attributes_for(:document) }
        let(:patch_request) do
          proc do
            patch :update, params: { id: relationship.id,
                                     relationship: { 'end_date' => '2001-01-01' },
                                     reference:  document_attributes }
          end
        end

        it 'redirects to relationship path' do
          patch_request.call
          expect(response).to redirect_to(relationship_path)
        end

        it 'updates db' do
          expect(&patch_request)
            .to change { Relationship.find(relationship.id).end_date }.from(nil).to('2001-01-01')
        end

        it 'updates last user id' do
          expect(&patch_request)
            .to change { Relationship.find(relationship.id).last_user_id }
                  .to(controller.current_user.id)
        end

        it 'creates 3 references' do
          expect(&patch_request).to change(Reference, :count).by(3)
        end

        it 'creates a new document' do
          expect(&patch_request).to change(Document, :count).by(1)
          expect(Document.last.url).to eql document_attributes[:url]
          expect(Document.last.name).to eql document_attributes[:name]
        end
      end
    end # end update start/end dates

    context 'With nested params: position relationship' do
      let(:relationship) do
        create(:relationship,
               entity1_id: e1.id, entity2_id: e2.id, category_id: 1, description1: 'leader')
      end

      let(:update_params) do
        {
          id: relationship.id,
          reference: { 'just_cleaning_up' => '1' },
          relationship: { 'notes' => 'notes notes notes',
                          'position_attributes' => { 'is_board' => 'true', 'compensation' => '1000' } }
        }
      end

      before { patch(:update, params: update_params) }

      it { should redirect_to(relationship_path) }

      it 'updates db' do
        expect(Relationship.find(relationship.id).get_category.is_board).to eql true
        expect(Relationship.find(relationship.id).get_category.compensation).to eql 1000
      end
    end
  end # end describe PATCH #update

  describe 'reverse_direction' do
    login_user

    let(:rel) { build(:relationship, id: rand(1000)) }

    before do
      expect(rel).to receive(:reverse_direction!)
      expect(Relationship).to receive(:find).with('1').and_return(rel)
      post :reverse_direction, params: { id: 1 }
    end

    it { is_expected.to respond_with(302) }
    it { is_expected.to redirect_to(edit_relationship_url(rel)) }
  end

  describe 'find_similar' do
    let(:org) { create(:entity_org) }
    let(:person) { create(:entity_person) }
    let!(:rel) { create(:position_relationship, entity: person, related: org, description1: 'influence') }

    login_user

    it 'returns bad_request if missing params' do
      get :find_similar
      expect(response).to have_http_status(:bad_request)
      get :find_similar, params: { 'entity1_id' => '123', 'entity2_id' => '456' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns good request if has all params' do
      get :find_similar,
          params: { 'entity1_id' => '123', 'entity2_id' => '456', 'category_id' => '1' }
      expect(response).to have_http_status(:ok)
    end

    it 'returns json with one similar relationships' do
      get :find_similar, params: { entity1_id: person.id, entity2_id: org.id, category_id: 1 }

      json = JSON.parse(response.body)

      expect(json.length).to eq 1
      expect(json[0]['id']).to eq rel.id
      expect(json[0]['description1']).to eq 'influence'
      expect(json[0].key?('last_user_id')).to be false
    end
  end

  describe "GET relationships/bulk_add" do
    login_user

    before do
      expect(Entity).to receive(:find).with('123').and_return(build(:person))
      get :bulk_add, params: { entity_id: 123 }
    end

    it { is_expected.to respond_with(200) }
    it { is_expected.to render_template(:bulk_add) }
    it { is_expected.to use_before_action(:authenticate_user!) }
    it { is_expected.to use_before_action(:set_entity) }
  end
end
