describe EntitiesController, type: :controller do
  include ::EntitiesHelper

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
    let(:entity) { create(:entity_org) }

    describe '/entity/id' do
      before { get :show, params: { id: entity.id } }

      it { is_expected.to render_template(:show) }
    end

    describe 'entity/id/datatable' do
      before { get :datatable, params: { id: entity.id } }

      it { is_expected.to render_template(:datatable) }
    end
  end

  describe '#edit' do
    login_user

    before do
      get :edit, params: { id: create(:entity_org).id }
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
    login_user

    describe 'Updating an Org without a reference' do
      let(:org) { create(:entity_org, last_user_id: example_user.id) }

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
        expect(org.last_user_id).to eq example_user.id
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
      let!(:org) { create(:entity_org) }
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
      let(:org) { create(:entity_org) }

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
end
