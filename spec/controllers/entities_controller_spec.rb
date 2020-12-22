describe EntitiesController, type: :controller do
  include EntitiesHelper

  it { is_expected.to use_before_action(:authenticate_user!) }
  it { is_expected.to use_before_action(:importers_only) }
  it { is_expected.to use_before_action(:set_entity) }

  describe 'routes' do
    it { is_expected.to route(:get, '/entities/1').to(action: :show, id: 1) }
    it { is_expected.to route(:get, '/entities/1/interlocks').to(action: :interlocks, id: 1) }
    it { is_expected.to route(:get, '/entities/1/giving').to(action: :giving, id: 1) }
    it { is_expected.to route(:get, '/entities/1/datatable').to(action: :datatable, id: 1) }
    it { is_expected.to route(:get, '/entities/1/add_relationship').to(action: :add_relationship, id: 1) }
    it { is_expected.to route(:get, '/entities/new').to(action: :new) }
    it { is_expected.to route(:post, '/entities').to(action: :create) }
    it { is_expected.to route(:post, '/entities/bulk').to(action: :create_bulk) }
    it { is_expected.to route(:get, '/entities/1/edit').to(action: :edit, id: 1) }
    it { is_expected.to route(:patch, '/entities/1').to(action: :update, id: 1) }
    it { is_expected.to route(:delete, '/entities/1').to(action: :destroy, id: 1) }
    it { is_expected.to route(:get, '/entities/1/political').to(action: :political, id: 1) }
    it { is_expected.to route(:get, '/entities/1/references').to(action: :references, id: 1) }
    it { is_expected.to route(:get, '/entities/1/match_donations').to(action: :match_donations, id: 1) }
    it { is_expected.to route(:post, '/entities/1/match_donation').to(action: :match_donation, id: 1) }
    it { is_expected.to route(:post, '/entities/1/unmatch_donation').to(action: :unmatch_donation, id: 1) }
    it { is_expected.to route(:get, '/entities/1/match_ny_donations').to(action: :match_ny_donations, id: 1) }
    it { is_expected.to route(:get, '/entities/1/review_donations').to(action: :review_donations, id: 1) }
    it { is_expected.to route(:get, '/entities/1/review_ny_donations').to(action: :review_ny_donations, id: 1) }
    it { is_expected.to route(:post, '/entities/1/tags').to(action: :tags, id: 1) }

    context 'with primary extensions' do
      let(:org) { build(:org) }
      let(:person) { build(:person) }

      specify do
        expect(:get => "/org/#{org.to_param}").to route_to(controller: "entities", action: "show", id: org.to_param)
        expect(:get => "/person/#{person.to_param}").to route_to(controller: "entities", action: "show", id: person.to_param)
      end
    end

    it 'routes names with periods' do
      org = build(:org, name: "X.Y.Z.")
      expect(:get => "/entities/#{org.to_param}").to route_to(controller: "entities", action: "show", id: org.to_param)
    end
  end

  describe 'GETs' do
    let(:entity) { create(:entity_org, updated_at: Time.current) }

    describe '/entity/id' do
      before { get :show, params: { id: entity.id } }

      it { is_expected.to render_template(:show) }
    end

    describe 'entity/id/datatable' do
      before { get :datatable, params: { id: entity.id } }

      it { is_expected.to render_template(:datatable) }
    end

    describe 'entity/id/contributions' do
      let(:entity) { build(:mega_corp_inc, updated_at: Time.current) }

      before do
        expect(Entity).to receive(:find_with_merges).and_return(entity)
        expect(entity).to receive(:contribution_info).and_return([build(:os_donation)])
        get :contributions, params: { id: entity.id }
      end

      it { is_expected.to respond_with(200) }

      it 'responds with json' do
        expect(response.headers['Content-Type']).to include 'application/json'
      end

      it 'sets cache headers' do
        expect(response.headers['Cache-Control']).to include 'public'
        expect(response.headers['Cache-Control']).to include 'max-age=300'
      end
    end

    describe '#match_donations and reivew donations' do
      let(:org) { build(:org) }

      context 'with match permissions' do
        login_user([:edit, :bulk])

        before do
          expect(Entity).to receive(:find_with_merges).and_return(org)
          expect(controller).to receive(:check_permission).with('importer').and_call_original
        end

        describe 'match_donations' do
          before { get(:match_donations, params: { id: rand(100) }) }

          it { is_expected.to redirect_to fec_entity_match_contributions_path(org) }
        end

        describe 'review_donations' do
          before { get(:review_donations, params: { id: rand(100) }) }

          it { is_expected.to render_template(:review_donations) }
          it { is_expected.to respond_with(200) }
        end
      end

      context 'without importer permissions' do
        login_basic_user

        before do
          expect(controller).to receive(:check_permission).with('importer').and_call_original
        end

        describe 'match_donations' do
          before { get(:match_donations, params: { id: rand(100) }) }

          it { is_expected.to respond_with(403) }
          it { is_expected.not_to render_template(:match_donations) }
        end

        describe 'review_donations' do
          before { get(:review_donations, params: { id: rand(100) }) }
          it { is_expected.to_not render_template(:review_donations) }
          it { is_expected.to respond_with(403) }
        end
      end
    end
  end

  describe '#create' do
    let(:params) { { "entity" => { "name" => "new entity", "blurb" => "a blurb goes here", "primary_ext" => "Org" } } }
    let(:params_missing_ext) { { "entity" => { "name" => "new entity", "blurb" => "a blurb goes here", "primary_ext" => "" } } }
    let(:params_add_relationship_page) { params.merge({ 'add_relationship_page' => 'TRUE' }) }
    let(:params_missing_ext_add_relationship_page) { params_missing_ext.merge({ 'add_relationship_page' => 'TRUE' }) }

    context 'user is logged in' do
      login_user

      context 'from the /entities/new page' do
        context 'without errors' do
          it 'redirects to edit url' do
            post :create, params: params
            expect(response).to redirect_to concretize_edit_entity_path(Entity.last)
          end

          it 'is_expected.to create a new entity' do
            expect { post :create, params: params }.to change { Entity.count }.by(1)
          end

          it "is_expected.to set last_user_id to be the user's id" do
            post :create, params: params
            expect(Entity.last.last_user_id).to eql controller.current_user.id
          end
        end

        context 'with errors' do
          it 'Renders new entities page' do
            post :create, params: params_missing_ext
            expect(response).to render_template(:new)
          end

          it 'sould NOT create a new entity' do
            expect { post :create, params: params_missing_ext }.not_to change { Entity.count }
          end
        end
      end

      describe 'from the /entities/id/add_relationship page' do
        context 'without errors' do
          it 'is_expected.to create a new entity' do
            expect { post :create, params: params_add_relationship_page }.to change { Entity.count }.by(1)
          end

          it 'is_expected.to render json with entity id' do
            post :create, params: params_add_relationship_page
            json = JSON.parse(response.body)
            expect(json.fetch('status')).to eql 'OK'
            expect(json['entity']['id']).to eql Entity.last.id
            expect(json['entity']).to have_key 'name'
            expect(json['entity']).to have_key 'url'
            expect(json['entity']).to have_key 'description'
            expect(json['entity']).to have_key 'primary_ext'
          end
        end

        context 'with errors' do
          it 'is_expected.to NOT create a new entity' do
            expect { post :create, params: params_missing_ext_add_relationship_page }
              .not_to change(Entity, :count)
          end

          it 'is_expected.to render json with errors' do
            post :create, params: params_missing_ext_add_relationship_page
            expect(JSON.parse(response.body)).to have_key 'errors'
            expect(JSON.parse(response.body).fetch('status')).to eql 'ERROR'
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'does not create a new entity' do
        expect { post :create, params: params_add_relationship_page }.not_to change { Entity.count }
      end

      it 'redirects to login page' do
        post :create, params: params
        expect(response.location).to include 'login'
        expect(response).to have_http_status 302
      end
    end

    xcontext 'user does not have contributors permission' do
      login_user_without_permissions

      it 'does not create a new entity' do
        expect { post :create, params: params }.not_to change(Entity, :count)
      end

      it 'returns http status 403' do
        post :create, params: params
        expect(response).to have_http_status 403
      end
    end

    context 'user is restricted' do
      login_restricted_user

      it 'does not create a new entity' do
        expect { post :create, params: params }.not_to change(Entity, :count)
      end

      it 'redirects to login page' do
        post :create, params: params
        expect(response).to have_http_status 302
        expect(response.location).to include '/home/dashboard'
      end
    end
  end # end of create

  describe 'Political' do
    let!(:entity) { create(:entity_org, updated_at: Time.current) }

    describe 'Political' do
      before { get(:political, params: { id: entity.id }) }

      it { is_expected.to render_template(:political) }
    end

    describe 'match/unmatch donations' do
      login_user([:edit, :bulk])

      let!(:entity) { create(:entity_org) }

      describe 'POST #match_donation' do
        before do
          expect(controller).to receive(:check_permission).and_call_original
          d1 = create(:os_donation, fec_cycle_id: 'unique_id_1')
          d2 = create(:os_donation, fec_cycle_id: 'unique_id_2')
          post :match_donation, params: { id: entity.id, payload: [d1.id, d2.id] }
        end

        it { is_expected.to respond_with(200) }
        it { is_expected.to use_before_action(:importers_only) }

        it "updates the entity's last user id after matching" do
          expect(entity.reload.last_user_id).to eql User.last.id
        end

        it 'sets the matched_by field of OsMatch' do
          OsMatch.last(2).each do |match|
            expect(match.matched_by).to eql User.last.id
            expect(match.user).to eql User.last
          end
        end
      end

      describe '#unmatch_donation' do
        specify do
          expect(controller).to receive(:check_permission).with('importer').and_call_original
          os_match = double('os match')
          expect(os_match).to receive(:destroy).exactly(3).times
          expect(OsMatch).to receive(:find).exactly(3).times.and_return(os_match)
          post :unmatch_donation, params: { id: entity.id, payload: [5, 6, 7] }
          expect(response).to have_http_status(200)
        end
      end

      describe '#match_ny_donations' do
        before do
          expect(controller).to receive(:check_permission).with('importer').and_call_original
          get :match_ny_donations, params: { id: entity.id }
        end

        it { is_expected.to respond_with(200) }
        it { is_expected.to render_template(:match_ny_donations) }
      end

      describe '#reiview_ny_donations' do
        before do
          expect(controller).to receive(:check_permission).with('importer').and_call_original
          get :review_ny_donations, params: { id: entity.id }
        end

        it { is_expected.to respond_with(200) }
        it { is_expected.to render_template(:review_ny_donations) }
      end
    end
  end # end political

  describe '#add_relationship' do
    login_user

    before do
      expect(Entity).to receive(:find_with_merges).and_return(build(:entity_org))
      get :add_relationship, params: { id: rand(100) }
    end

    it { is_expected.to render_template(:add_relationship) }
    it { is_expected.to respond_with(200) }
  end

  describe '#edit' do
    login_user

    before do
      expect(Entity).to receive(:find_with_merges).and_return(build(:org))
      get :edit, params: { id: rand(100) }
    end

    it { is_expected.to render_template(:edit) }
    it { is_expected.to respond_with(200) }
  end

  describe 'when user is not logged in' do
    let(:org) { create(:entity_org) }

    before { get :edit, params: { id: org.id } }

    it { is_expected.to respond_with 302 }
  end

  describe '#update' do
    let(:user) { create(:user) }
    login_user

    describe 'Updating an Org without a reference' do
      let(:org) { create(:entity_org, last_user_id: user.id) }
      let(:params) do
        { id: org.id, entity: { 'website' => 'http://example.com' }, reference: { 'just_cleaning_up' => '1' } }
      end

      it 'updates entity field' do
        expect(org.website).to be nil
        patch :update, params: params
        expect(Entity.find(org.id).website).to eq 'http://example.com'
      end

      it 'does not create a new reference' do
        expect { patch :update, params: params }.not_to change { Reference.count }
      end

      it 'updates last_user_id' do
        expect(org.last_user_id).to eq user.id
        patch :update, params: params
        expect(Entity.find(org.id).last_user_id).to eq controller.current_user.id
      end
    end

    describe 'Updating an Org with a reference' do
      let(:org) { create(:entity_org) }
      let(:params) do
        { id: org.id,
          entity: { 'start_date' => '1929-08-08' },
          reference: { 'url' => 'http://example.com', 'name' => 'new reference' } }
      end

      it 'updates entity field' do
        expect(org.start_date).to be nil
        patch :update, params: params
        expect(Entity.find(org.id).start_date).to eq '1929-08-08'
      end

      it 'creates a new reference' do
        expect { patch :update, params: params }.to change(Reference, :count).by(1)
      end

      it 'redirects to legacy url' do
        patch :update, params: params
        expect(response).to redirect_to concretize_entity_path(org)
      end
    end

    describe 'Updating a Person without a reference' do
      let(:person) { create(:entity_person) }
      let(:params) do
        { id: person.id,
          entity: { 'blurb' => 'just a person',
                    'person_attributes' => { 'name_middle' => 'MIDDLE', 'id' => person.person.id } },
          reference: { 'reference_id' => '123' } }
      end

      it 'updates entity field' do
        expect(person.blurb).to be nil
        patch :update, params: params
        expect(Entity.find(person.id).blurb).to eq 'just a person'
      end

      it 'updates person model' do
        expect(person.person.name_middle).to be nil
        patch :update, params: params
        expect(Entity.find(person.id).person.name_middle).to eq 'MIDDLE'
      end

      it 'does not create a new reference' do
        expect { patch :update, params: params }.not_to change(Reference, :count)
      end

      it 'redirects to legacy url' do
        patch :update, params: params
        expect(response).to redirect_to concretize_entity_path(person)
      end
    end

    describe 'adding and removing types' do
      let!(:org) { create(:entity_org, last_user_id: user.id) }
      let(:extension_def_ids) { '' }
      let(:params) do
        { id: org.id,
          entity: { 'extension_def_ids' => extension_def_ids },
          reference: { 'url' => 'http://example.com', 'name' => 'new reference' } }
      end

      describe 'adding new types' do
        let(:extension_def_ids) { '8,9,10' }

        it 'is_expected.to create 3 new extension records' do
          expect { patch :update, params: params }.to change(ExtensionRecord, :count).by(3)
        end

        it 'redirects to legacy url' do
          patch :update, params: params
          expect(response).to redirect_to concretize_entity_path(org)
        end
      end

      describe 'removing types' do
        let(:extension_def_ids) { '' }

        before { org.add_extension('School') }

        it 'is_expected.to remove one extension records' do
          expect { patch :update, params: params }.to change(ExtensionRecord, :count).by(-1)
        end

        it 'is_expected.to remove School model' do
          expect { patch :update, params: params }.to change(School, :count).by(-1)
        end

        it 'redirects to legacy url' do
          patch :update, params: params
          expect(response).to redirect_to concretize_entity_path(org)
        end
      end
    end

    describe 'updating an Org with errors' do
      let(:org) { create(:entity_org, last_user_id: user.id) }
      let(:params) do
        { id: org.id, entity: { 'end_date' => 'bad date' }, reference: { 'just_cleaning_up' => '1' } }
      end

      it 'does not change the end_date' do
        expect { patch :update, params: params }.not_to change { Entity.find(org.id).end_date }
      end

      it 'renders edit page' do
        patch :update, params: params
        expect(response).to render_template('edit')
      end
    end

    describe 'updating a person with a first name that is too long' do
      let(:person) { create(:entity_person) }
      let(:params) do
        { id: person.id,
          entity: { 'blurb' => 'new blurb',
                    'person_attributes' => { 'name_first' => "#{'x' * 51}",
                                             'id' => person.person.id } },
          reference: { 'reference_id' => '123' } }
      end

      it 'does not change the first name' do
        expect { patch :update, params: params }.not_to change { Entity.find(person.id).person.name_first }
      end

      it 'does not change the entity\'s blurb' do
        expect { patch :update, params: params }.not_to change { Entity.find(person.id).blurb }
      end

      it 'renders edit page' do
        patch :update, params: params
        expect(response).to render_template('edit')
      end
    end

    describe 'updating a public company' do
      let(:public_company) { create(:public_company_entity) }
      let(:params) do
        { id: public_company.id,
          entity: {
            name: public_company.name,
            public_company_attributes: {
              id: public_company.public_company.id,
              ticker: 'ABC'
            },
            business_attributes: {
              id: public_company.business.id,
              annual_profit: 999,
              assets: 100,
              marketcap: 200,
              net_income: 300
            }
          },
          reference: { 'url' => 'http://example.com', 'name' => 'new reference' } }
      end

      it 'updates ticker' do
        expect(Entity.find(public_company.id).public_company.ticker).to eq 'XYZ'
        expect { patch :update, params: params }.to change { PublicCompany.find(public_company.public_company.id).ticker }.to('ABC')
      end

      it 'updates business fields' do
        patch :update, params: params
        expect(public_company.business.reload).to have_attributes(annual_profit: 999, assets: 100, marketcap: 200, net_income: 300)
      end

      it 'redirects to entity url' do
        patch :update, params: params
        expect(response).to redirect_to concretize_entity_path(public_company)
      end
    end
  end # end describe #update

  describe 'validate' do
    it 'returns validation errors for invalid entities' do
      post :validate, params: { entity: { name: 'Mr Aesop', blurb: 'Hic Rhodus hic salta', primary_ext: '' } }

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      expect(body["name"].first).to eq("Could not find a first name. Mr is a common prefix")
      expect(body["primary_ext"].first).to eq("can't be blank")
    end

    it 'returns nothing for valid entities' do
      post :validate, params: { entity: { name: 'Carl Schmitt', blurb: 'The exception proves everything.', primary_ext: 'org' } }

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      expect(body).to eq({})
    end
  end

  describe '#destory' do
    context 'when user is not a deleter' do
      before { delete :destroy, params: { id: '123' } }

      it { is_expected.to respond_with 302 }
    end
  end

  describe 'adding to lists' do
    let(:user) { create(:user) }
    let(:public_company) { create(:public_company_entity) }
    let(:params) { { id: public_company.id, list_id: list.id } }

    before do
      user.add_ability(:list)
      sign_in(user)
    end

    context 'when the list is private to the signed in user' do
      let(:list) { create(:list, user: user, access: Permissions::ACCESS_PRIVATE) }

      it 'adds the entity to the list' do
        expect { post :add_to_list, params: params }.to change(list.entities, :count).by(1)
      end
    end

    context 'when the list is private to someone else' do
      let(:list) { create(:list, user: create(:user), access: Permissions::ACCESS_PRIVATE) }

      it 'is forbidden' do
        post :add_to_list, params: params
        expect(response).to be_forbidden
      end

      it "doesn't add the entity to the list" do
        expect { post :add_to_list, params: params }.not_to change(list.entities, :count)
      end
    end

    context 'when the list is open for edits' do
      let(:list) { create(:list, access: Permissions::ACCESS_OPEN) }

      it 'adds the entity to the list' do
        expect { post :add_to_list, params: params }.to change(list.entities, :count).by(1)
      end
    end

    context 'when the list is closed' do
      let(:list) { create(:list, access: Permissions::ACCESS_CLOSED) }

      it 'is forbidden' do
        post :add_to_list, params: params
        expect(response).to be_forbidden
      end

      it "doesn't add the entity to the list" do
        expect { post :add_to_list, params: params }.not_to change(list.entities, :count)
      end
    end

    context "when the user doesn't have list permissions" do
      let(:list) { create(:list, access: Permissions::ACCESS_OPEN) }

      before do
        sign_out(user)
        sign_in(create(:user))
      end

      it 'is forbidden' do
        post :add_to_list, params: params
        expect(response).to be_forbidden
      end

      it "doesn't add the entity to the list" do
        expect { post :add_to_list, params: params }.not_to change(list.entities, :count)
      end
    end

    context "when there is no signed in user" do
      let(:list) { create(:list, access: Permissions::ACCESS_OPEN) }

      before do
        sign_out(user)
      end

      it 'is redirected' do
        post :add_to_list, params: params
        expect(response).to be_redirect
      end

      it "doesn't add the entity to the list" do
        expect { post :add_to_list, params: params }.not_to change(list.entities, :count)
      end
    end
  end
end
