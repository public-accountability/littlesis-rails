require 'rails_helper'

describe RelationshipsController, type: :controller do
  let(:sf_user) { create(:sf_user) }
  let(:e1) { create(:person, last_user_id: sf_user.id, created_at: 1.day.ago, updated_at: 1.day.ago) }
  let(:e2) { create(:mega_corp_inc, last_user_id: sf_user.id, created_at: 1.day.ago, updated_at: 1.day.ago) }

  before(:all) do
    Entity.skip_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.start
  end

  after(:all) do
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end

  it { should route(:get, '/relationships/1').to(action: :show, id: 1) }
  it { should route(:post, '/relationships').to(action: :create) }
  it { should route(:get, '/relationships/1/edit').to(action: :edit, id: 1) }
  it { should route(:post, '/relationships/1/reverse_direction').to(action: :reverse_direction, id: 1) }
  it { should route(:patch, '/relationships/1').to(action: :update, id: 1) }
  it { should route(:delete, '/relationships/1').to(action: :destroy, id: 1) }
  it { should route(:post, '/relationships/bulk_add').to(action: :bulk_add) }
  it { should route(:get, '/relationships/find_similar').to(action: :find_similar) }

  describe 'GET #show' do
    before do
      @rel = build(:relationship)
      expect(Relationship).to receive(:find).with('1').and_return(@rel)
      get :show, id: 1
    end

    it { should respond_with(:success) }
    it { should render_template(:show) }

    it 'assigns relationship' do
      expect(assigns(:relationship)).to eql @rel
    end
  end

  describe 'POST #create' do
    login_admin

    def example_params(entity1_id='10', entity2_id='20')
      {
        relationship: {
          entity1_id: entity1_id,
          entity2_id: entity2_id,
          category_id: '1'
        },
        reference: {
          name: 'Interesting website',
          source_detail: '',
          source: 'http://example.com',
          publication_date: '2016-01-01',
          ref_type: '1'
        }
      }
    end

    context 'with valid params' do
      def post_request
        post :create, example_params(e1.id, e2.id)
      end

      it 'responds with 201' do
        post_request
        expect(response.status).to eq 201
      end

      it 'sends back json with relationship_id' do
        post_request
        expect(JSON.parse(response.body)).to eql ({ "relationship_id" => Relationship.last.id})
      end

      it 'should create a new relationship' do
        expect { post_request }.to change { Relationship.count }.by(1)
      end

      it 'should create a new Reference' do
        expect { post_request }.to change { Reference.count }.by(1)
      end

      it 'should create reference with correct fields' do
        post_request
        r = Reference.last
        expect(r.name).to eql 'Interesting website'
        expect(r.ref_type).to eql 1
        expect(r.object_model).to eql 'Relationship'
        expect(r.object_id). to eql Relationship.last.id
      end

      it 'changes updated_at of entities' do
        e1.update_column(:updated_at, 1.day.ago)
        e2.update_column(:updated_at, 1.day.ago)
        e1_updated_at = e1.updated_at
        e2_updated_at = e2.updated_at
        post_request
        expect(Entity.find(e1.id).updated_at.to_i).not_to eql e1_updated_at.to_i
        expect(Entity.find(e2.id).updated_at.to_i).not_to eql e2_updated_at.to_i
      end

      it 'updates last_user_id' do
        post_request
        expect(Entity.find(e1.id).last_user_id).not_to eql sf_user.id
        expect(Entity.find(e2.id).last_user_id).not_to eql sf_user.id
      end
    end

    context 'with invalid params' do
      it 'responds with 400 if missing category_id' do
        post :create, example_params.tap { |x| x[:relationship].delete(:category_id) }
        expect(response.status).to eq 400
      end

      it 'sends error json with bad relationship params' do
        post :create, example_params.tap { |x| x[:relationship].delete(:category_id) }
        expect(JSON.parse(response.body)).to have_key 'relationship'
        expect(JSON.parse(response.body)).to have_key 'reference'
        expect(JSON.parse(response.body)['relationship']).to have_key 'category_id'
      end

      it 'responds with 400 if missing reference source' do
        post :create, example_params(entity1_id: e1.id, entity2_id: e2.id).tap { |x| x[:reference].delete(:source) }
        expect(response.status).to eq 400
      end

      it 'sends error json with reference params' do
        post :create,  example_params(entity1_id: e1.id, entity2_id: e2.id).tap { |x| x[:reference].delete(:source) }
        expect(JSON.parse(response.body)).to have_key 'relationship'
        expect(JSON.parse(response.body)).to have_key 'reference'
        expect(JSON.parse(response.body)['reference']). to have_key 'source'
        expect(JSON.parse(response.body)['relationship']).not_to have_key 'category_id'
      end

      it 'sends error json with reference & relationship params' do
        post :create, example_params.tap { |x| x[:reference].delete(:source) }.tap { |x| x[:relationship].delete(:category_id) }
        expect(JSON.parse(response.body)['reference']).to have_key 'source'
        expect(JSON.parse(response.body)['relationship']).to have_key 'category_id'
      end
    end

    context 'submitting relationship with is_current values' do
      it 'should create a new relationship with given a yes value' do
        expect do
          post :create, example_params(e1.id, e2.id).tap { |x| x[:relationship][:is_current] = 'YES' }
        end.to change { Relationship.count }.by(1)
        id_of_created_relationship = JSON.parse(response.body)['relationship_id']
        expect(Relationship.find(id_of_created_relationship).is_current).to eq true
      end

      it 'should create a new relationship with given a NO value' do
        expect do
          post :create, example_params(e1.id, e2.id).tap { |x| x[:relationship][:is_current] = 'NO' }
        end.to change { Relationship.count }.by(1)
        id_of_created_relationship = JSON.parse(response.body)['relationship_id']
        expect(Relationship.find(id_of_created_relationship).is_current).to eq false
      end

      it 'should create a new relationship with given a NULL value' do
        expect do
          post :create, example_params(e1.id, e2.id).tap { |x| x[:relationship][:is_current] = 'NULL' }
        end.to change { Relationship.count }.by(1)
        id_of_created_relationship = JSON.parse(response.body)['relationship_id']
        expect(Relationship.find(id_of_created_relationship).is_current).to be nil
      end
    end

    describe 'params' do
      before do
        r = build(:generic_relationship)
        allow(r).to receive(:save!)
        allow(Relationship).to receive(:new).and_return(r)
      end

      it do
        should permit(:entity1_id, :entity2_id, :category_id, :is_current)
                .for(:create, params: example_params).on(:relationship)
      end

      it do
        should permit(:name, :source, :source_detail, :publication_date, :ref_type)
                .for(:create, params: example_params).on(:reference)
      end
    end
  end # end describe POST #create

  describe 'DELETE /relationship/id' do
    login_user
    
    it 'destroys relationship and redirects to dashboard' do
      @rel = build :relationship
      expect(Relationship).to receive(:find).with('1').and_return(@rel)
      expect(@rel).to receive(:soft_delete).once
      delete :destroy, { id: '1' }
      expect(response).to have_http_status 302
      expect(response.location).to include '/home/dashboard'
    end
    
  end

  describe 'GET /relationships/id/edit' do
    login_user

    context 'editing a reference' do
      before do
        @rel = build :relationship
        expect(Relationship).to receive(:find).with('1').and_return(@rel)
        get :edit, id: 1
      end

      it { should respond_with(:success) }
      it { should render_template(:edit) }
    end

    context 'editing a reference directly after created it (new_ref = true)' do
      context 'when there is no reference' do
        before do
          @rel = build :relationship
          expect(Relationship).to receive(:find).with('1').and_return(@rel)
          get :edit, id: 1, new_ref: 'true'
        end

        it { should respond_with(:success) }
        it { should render_template(:edit) }

        it 'sets @selected_ref to be nil' do
          expect(assigns(:selected_ref)).to eql nil
        end
      end

      context 'when there is a reference' do
        before do
          @rel = build(:relationship)
          @ref = build(:relationship_ref)
          expect(@rel).to receive(:references).and_return(double(:last => @ref))
          expect(Relationship).to receive(:find).with('1').and_return(@rel)
          get :edit, id: 1, new_ref: 'true'
        end

        it { should respond_with(:success) }
        it { should render_template(:edit) }

        it 'sets @selected_ref' do
          expect(assigns(:selected_ref)).to eql @ref.id
        end
      end
    end
  end

  describe 'PATCH /relationships/id' do
    login_user

    let(:generic_reference) do
      create(:generic_relationship, entity1_id: e1.id, entity2_id: e2.id, category_id: 12, last_user_id: sf_user.id)
    end

    context 'When the submission contains errors' do
      before do
        @rel = generic_reference
        e1.update_column(:updated_at, 1.day.ago)
        e2.update_column(:updated_at, 1.day.ago)
        @e1_updated_at = e1.updated_at
        @e2_updated_at = e2.updated_at
        patch :update, { id: @rel.id, relationship: {'start_date' => '012345678910'}, reference: {'just_cleaning_up' => '1'} }
      end

      it { should respond_with(:success) }
      it { should render_template(:edit) }

      it 'does not change the  updated_at of entities' do
        expect(Entity.find(e1.id).updated_at.to_i).to eql @e1_updated_at.to_i
        expect(Entity.find(e2.id).updated_at.to_i).to eql @e2_updated_at.to_i
      end

      it 'does not update last_user_id' do
        expect(Entity.find(e1.id).last_user_id).to eql sf_user.id
        expect(Entity.find(e2.id).last_user_id).to eql sf_user.id
      end
    end

    context "it's a good request" do
      before do
        @e1 = create(:person, last_user_id: sf_user.id, created_at: 1.day.ago, name: 'person one')
        @e2 = create(:mega_corp_inc, last_user_id: sf_user.id, created_at: 1.day.ago)
        @rel = create(:generic_relationship, entity1_id: @e1.id, entity2_id: @e2.id)
        @e1.update_column(:updated_at, 1.day.ago)
        @e2.update_column(:updated_at, 1.day.ago)
        @e1_updated_at = @e1.updated_at
        @e2_updated_at = @e2.updated_at
        patch :update, { id: @rel.id, relationship: {'start_date' => '2012-12-12'}, reference: {'reference_id' => '123'} }
      end

      it { should redirect_to(relationship_path) }

      it 'updates db' do
        expect(Relationship.find(@rel.id).start_date).to eql '2012-12-12'
      end

      it 'changes updated_at of entities' do
        expect(Entity.find(@e1.id).updated_at.to_i).not_to eql @e1_updated_at.to_i
        expect(Entity.find(@e2.id).updated_at.to_i).not_to eql @e2_updated_at.to_i
      end

      it 'updates last_user_id' do
        expect(Entity.find(@e1.id).last_user_id).not_to eql sf_user.id
        expect(Entity.find(@e2.id).last_user_id).not_to eql sf_user.id
      end
    end

    context 'with blank string as start and end date' do
      before do
        @rel = generic_reference
        patch :update, { id: @rel.id, relationship: {'start_date' => '', 'end_date' => ''}, reference: {'reference_id' => '123'} }
      end
      
      it 'keeps start_date as nil' do
        expect(Relationship.find(@rel.id).start_date).to be nil
      end
      
      it 'keeps end_date as nil' do
        expect(Relationship.find(@rel.id).end_date).to be nil
      end
    end

    context 'with alternative date formats' do
      before { @rel = generic_reference }

      it 'allows date as YYYY' do
        patch :update, { id: @rel.id, relationship: { 'start_date' => '2017' }, reference: { 'reference_id' => '123' } }
        expect(Relationship.find(@rel.id).start_date).to eql '2017-00-00'
      end

      it 'allows date as YYYY-MM' do
        patch :update, { id: @rel.id, relationship: { 'end_date' => '2017-09' }, reference: { 'reference_id' => '123' } }
        expect(Relationship.find(@rel.id).end_date).to eql '2017-09-00'
      end

      it 'allows date as YYYYMMDD' do
        patch :update, { id: @rel.id, relationship: { 'end_date' => '20170925' }, reference: { 'reference_id' => '123' } }
        expect(Relationship.find(@rel.id).end_date).to eql '2017-09-25'
      end
    end

    context 'invalid reference' do
      before do
        @rel = generic_reference
        patch :update, { id: @rel.id, relationship: {'start_date' => '2001-01-01'}, reference: {'source' => '', 'name' => ''} }
      end

      it { should render_template(:edit) }

      it 'does not update relationship' do
        expect(Relationship.find(@rel.id).start_date).to be nil
      end
    end

    context 'good request with new reference' do
      before do
        @rel = generic_reference
        @ref_count = Reference.count
        patch :update, { id: @rel.id, relationship: {'end_date' => '2001-01-01'}, reference: {'source' => 'http://example.com', 'name' => 'example'} }
      end

      it { should redirect_to(relationship_path) }

      it 'updates db' do
        expect(Relationship.find(@rel.id).end_date).to eql '2001-01-01'
      end

      it 'updates last user id' do
        expect(Relationship.find(@rel.id).last_user_id). to eql controller.current_user.sf_guard_user_id
      end

      it 'creates a new reference' do
        expect(Reference.count).to eql (@ref_count + 1)
        expect(Reference.last.source).to eql 'http://example.com'
        expect(Reference.last.name).to eql 'example'
      end
    end

    context 'With nested params: position relationship' do
      before do
        @rel = create(:relationship, entity1_id: e1.id, entity2_id: e2.id, category_id: 1, description1: 'leader')
        patch(:update, { id: @rel.id, reference: {'just_cleaning_up' => '1'}, relationship: {'notes' => 'notes notes notes', 'position_attributes' => { 'is_board' => 'true', 'compensation' => '1000' } } })
      end

      it { should redirect_to(relationship_path) }

      it 'updates db' do
        expect(Relationship.find(@rel.id).get_category.is_board).to eql true
        expect(Relationship.find(@rel.id).get_category.compensation).to eql 1000
      end
    end
  end # end describe PATCH #update

  describe 'reverse_direction' do
    login_user
    before do
      @rel = build(:relationship, id: rand(1000))
      expect(@rel).to receive(:reverse_direction)
      expect(Relationship).to receive(:find).with('1').and_return(@rel)
      post :reverse_direction, id: 1
    end

    it { should respond_with(302) }
    it { should redirect_to(edit_relationship_url(@rel)) }
  end

  describe 'find_similar' do
    login_user

    it 'returns bad_request if missing params' do
      get :find_similar
      expect(response).to have_http_status(:bad_request)
      get :find_similar, { 'entity1_id' => '123', 'entity2_id' => '456' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns good request if has all params' do
      get :find_similar, { 'entity1_id' => '123', 'entity2_id' => '456', 'category_id' => '1' }
      expect(response).to have_http_status(:ok)
    end

    it 'returns json with one similar relationships' do
      org = create :org
      person = create :person
      rel = Relationship.create!(entity: person, related: org, category_id: 1, description1: 'influence')

      get :find_similar, { entity1_id: person.id, entity2_id: org.id, category_id: 1 }

      json = JSON.parse(response.body)

      expect(json.length).to eq 1
      expect(json[0]['id']).to eq rel.id
      expect(json[0]['description1']).to eq 'influence'
      expect(json[0].key?('last_user_id')).to be false
    end
  end
end
