require 'rails_helper'

describe EntitiesController, type: :controller do
  before(:all) { DatabaseCleaner.start }
  after(:all)  { DatabaseCleaner.clean }

  it { should use_before_action(:authenticate_user!) }
  it { should use_before_action(:importers_only) }
  it { should use_before_action(:set_entity) }

  describe 'routes' do
    it { should route(:get, '/entities/1').to(action: :show, id: 1) }
    it { should route(:get, '/entities/1/relationships').to(action: :relationships, id: 1) }
    it { should route(:get, '/entities/1/add_relationship').to(action: :add_relationship, id: 1) }
    it { should route(:get, '/entities/new').to(action: :new) }
    it { should route(:post, '/entities').to(action: :create) }
    it { should route(:get, '/entities/1/edit').to(action: :edit, id: 1) }
    it { should route(:patch, '/entities/1').to(action: :update, id: 1) }
    it { should route(:get, '/entities/1/political').to(action: :political, id: 1) }
    it { should route(:get, '/entities/1/references').to(action: :references, id: 1) }
    it { should route(:get, '/entities/1/match_donations').to(action: :match_donations, id: 1) }
    it { should route(:post, '/entities/1/match_donation').to(action: :match_donation, id: 1) }
    it { should route(:post, '/entities/1/unmatch_donation').to(action: :unmatch_donation, id: 1) }
    it { should route(:get, '/entities/1/match_ny_donations').to(action: :match_ny_donations, id: 1) }
    it { should route(:get, '/entities/1/review_donations').to(action: :review_donations, id: 1) }
    it { should route(:get, '/entities/1/review_ny_donations').to(action: :review_ny_donations, id: 1) }
  end

  describe 'GETs' do
    before(:all) do
      @entity = create(:mega_corp_inc, updated_at: Time.now)
    end

    describe "/entity/id" do
      before { get(:show, id: @entity.id) }

      it { should render_template(:show) }

      it 'sets the entity var' do
        expect(assigns(:entity).id).to eql @entity.id
      end
    end

    describe 'entity/id/relationships' do
      before { get(:relationships, id: @entity.id) }
      it { should render_template(:relationships) }
    end

    describe '#match_donations and reivew donations' do
      before do
        expect(Entity).to receive(:find).once
        expect(controller).to receive(:check_permission).with('importer').and_call_original
      end

      context 'user with importer permissions' do
        login_user
        describe 'match_donations' do
          before { get(:match_donations, id: rand(100)) }
          it { should render_template(:match_donations) }
          it { should respond_with(200) }
        end

        describe 'review_donations' do
          before { get(:review_donations, id: rand(100)) }
          it { should render_template(:review_donations) }
          it { should respond_with(200) }
        end
      end

      context 'user without importer permissions' do
        login_basic_user
        describe 'match_donations' do
          before { get(:match_donations, id: rand(100)) }
          it { should respond_with(403) }
          it { should_not render_template(:match_donations) }
        end

        describe 'review_donations' do
          before { get(:review_donations, id: rand(100)) }
          it { should_not render_template(:review_donations) }
          it { should respond_with(403) }
        end
      end
    end
  end

  describe '#create' do
    login_user
    let(:params) { {"entity"=>{"name"=>"new entity", "blurb"=>"a blurb goes here", "primary_ext"=>"Org" } } }
    let(:params_missing_ext) { {"entity"=>{"name"=>"new entity", "blurb"=>"a blurb goes here", "primary_ext"=>"" } } }
    let(:params_add_relationship_page) { params.merge({'add_relationship_page' => 'TRUE'}) }
    let(:params_missing_ext_add_relationship_page) { params_missing_ext.merge({ 'add_relationship_page' => 'TRUE' }) }

    context 'from the /entities/new page' do
      context 'without errors' do
        it 'redirects to edit url' do
          post :create, params
          expect(response).to redirect_to(Entity.last.legacy_url('edit'))
        end

        it 'should create a new entity' do
          expect { post :create, params }.to change { Entity.count }.by(1)
        end

        it "should set last_user_id to be the user's sf guard user id" do
          post :create, params
          expect(Entity.last.last_user_id).to eql controller.current_user.sf_guard_user_id
        end
      end

      context 'with errors' do
        it 'Renders new entities page' do
          post :create, params_missing_ext
          expect(response).to render_template(:new)
        end

        it 'sould NOT create a new entity' do
          expect { post :create, params_missing_ext }.not_to change { Entity.count }
        end
      end
    end

    context 'from the /entiites/id/add_relationship page' do
      context 'without errors' do
        it 'should create a new entity' do
          expect { post :create, params_add_relationship_page }.to change { Entity.count }.by(1)
        end

        it 'should render json with entity id' do
          post :create, params_add_relationship_page
          json = JSON.parse(response.body)
          expect(json.fetch('status')).to eql 'OK'
          expect(json['entity']['id']).to eql Entity.last.id
          expect(json['entity']).to have_key 'name'
          expect(json['entity']).to have_key 'url'
          expect(json['entity']).to have_key 'description'
          expect(json['entity']).to have_key 'primary_type'
        end
      end

      context 'with errors' do
        it 'should NOT create a new entity' do
          expect { post :create, params_missing_ext_add_relationship_page }
            .not_to change { Entity.count }
        end

        it 'should render json with errors' do
          post :create, params_missing_ext_add_relationship_page
          expect(JSON.parse(response.body)).to have_key 'errors'
          expect(JSON.parse(response.body).fetch 'status').to eql 'ERROR'
        end
      end
    end
  end

  describe 'Political' do
    before { @entity = create(:mega_corp_inc, updated_at: Time.now) }

    describe 'Political' do
      before { get(:political, id: @entity.id) }
      it { should render_template(:political) }
    end

    describe 'match/unmatch donations' do
      login_user

      before(:all) { @entity = create(:mega_corp_inc) }

      describe 'POST #match_donation' do
        before(:each) do
          expect(controller).to receive(:check_permission).and_call_original
          d1 = create(:os_donation, fec_cycle_id: 'unique_id_1')
          d2 = create(:os_donation, fec_cycle_id: 'unique_id_2')
          post :match_donation, id: @entity.id, payload: [d1.id, d2.id]
        end

        it { should respond_with(200) }
        it { should use_before_action(:importers_only) }

        it "updates the entity's last user id after matching" do
          expect(@entity.reload.last_user_id).to eql SfGuardUser.last.id
        end

        it 'sets the matched_by field of OsMatch' do
          OsMatch.last(2).each do |match|
            expect(match.matched_by).to eql User.last.id
            expect(match.user).to eql User.last
          end
        end
      end

      describe 'Clearing Cache' do
        def setup
          allow(OsMatch).to receive(:find_or_create_by!) { double('osmatch').as_null_object }
          mock_entity = instance_double('Entity')
          mock_delay = double('delay')
          expect(mock_delay).to receive(:clear_legacy_cache)
          expect(mock_entity).to receive(:delay) { mock_delay }
          expect(mock_entity).to receive(:update)
          expect(Entity).to receive(:find).with('7').and_return(mock_entity)
        end

        before { OsMatch.skip_callback :create, :after, :post_process }
        after { OsMatch.set_callback :create, :after, :post_process }

        it 'deletes legacy cache on match' do
          setup
          post :match_donation, id: 7, payload: [1]
        end
      end

      describe '#unmatch_donation' do
        before do
          expect(controller).to receive(:check_permission).with('importer').and_call_original
          @os_match = double('os match')
          expect(@os_match).to receive(:destroy).exactly(3).times
          expect(OsMatch).to receive(:find).exactly(3).times.and_return(@os_match)
          post :unmatch_donation, id: @entity.id, payload: [5, 6, 7]
        end

        it { should respond_with(200) }
      end

      describe '#match_ny_donations' do
        before do
          expect(controller).to receive(:check_permission).with('importer').and_call_original
          get(:match_ny_donations, id: @entity.id)
        end
        it { should respond_with(200) }
        it { should render_template(:match_ny_donations) }
      end

      describe '#reiview_ny_donations' do
        before do
          expect(controller).to receive(:check_permission).with('importer').and_call_original
          get(:review_ny_donations, id: @entity.id)
        end
        it { should respond_with(200) }
        it { should render_template(:review_ny_donations) }
      end
    end
  end # end political

  describe '#add_relationship' do
    login_user
    before do
      expect(Entity).to receive(:find)
      get :add_relationship, id: rand(100)
    end
    it { should render_template(:add_relationship) }
    it { should respond_with(200) }
  end

  describe '#edit' do
    login_user

    before do
      expect(Entity).to receive(:find).and_return(build(:org))
      get :edit, id: rand(100)
    end
    it { should render_template(:edit) }
    it { should respond_with(200) }
  end

  describe '#update' do
    let(:sf_guard_user) { create(:sf_user) }
    login_user

    context 'Updating an Org without a reference' do
      let(:org)  { create(:org, last_user_id: sf_guard_user.id) }
      let(:params) { { id: org.id, entity: { 'website' => 'http://example.com' }, reference: {'just_cleaning_up' => '1'} } }

      it 'updates entity field' do
        expect(org.website).to be nil
        patch :update, params
        expect(Entity.find(org.id).website).to eq 'http://example.com'
      end

      it 'does not create a new reference' do
        expect { patch :update, params }.not_to change { Reference.count }
      end

      it 'updates last_user_id' do
        expect(org.last_user_id).to eq sf_guard_user.id
        patch :update, params
        expect(Entity.find(org.id).last_user_id).to eq controller.current_user.sf_guard_user.id
      end
    end

    context 'Updating an Org with a reference' do
      let(:org) { create(:org) }
      let(:params) { { id: org.id,
                       entity: { 'start_date' => '1929-08-08' },
                       reference: { 'source' => 'http://example.com', 'name' => 'new reference' } } }
    
      it 'updates entity field' do
        expect(org.start_date).to be nil
        patch :update, params
        expect(Entity.find(org.id).start_date).to eq '1929-08-08'
      end

      it 'creates a new reference' do
        expect { patch :update, params }.to change { Reference.count }.by(1)
        expect(Reference.last.name).to eq 'new reference'
      end
      
      it 'redirects to legacy url' do
        patch :update, params
        expect(response).to redirect_to(org.legacy_url)
      end
      
    end

    context 'Updating a Person without a reference' do
      let(:person) { create(:person) }
      let(:params) { { id: person.id,
                       entity: { 'blurb' => 'just a person',
                                  'person_attributes' => { 'name_middle' => 'MIDDLE', 'id' => person.person.id } },
                       reference: { 'reference_id' => '123'} } }
      
      it 'updates entity field' do
        expect(person.blurb).to be nil
        patch :update, params
        expect(Entity.find(person.id).blurb).to eq 'just a person'
      end

      it 'updates person model' do
        expect(person.person.name_middle).to be nil
        patch :update, params
        expect(Entity.find(person.id).person.name_middle).to eq 'MIDDLE'
      end

      it 'does not create a new reference' do
        expect { patch :update, params }.not_to change { Reference.count }
      end

      it 'redirects to legacy url' do
        patch :update, params
        expect(response).to redirect_to(person.legacy_url)
      end
    end

    describe 'adding new types' do
      before do
        @org = create(:org, last_user_id: sf_guard_user.id)
        @params = { id: @org.id,
                    entity: { 'extension_def_ids' => '8,9,10' },
                    reference: { 'source' => 'http://example.com', 'name' => 'new reference' } }
      end
      
      it 'should create 3 new extension records' do
        expect { patch :update, @params }.to change { ExtensionRecord.count }.by(3)
      end

      it 'redirects to legacy url' do
        patch :update, @params
        expect(response).to redirect_to(@org.legacy_url)
      end
    end

    describe 'removing types' do
      before do
        @org = create(:org, last_user_id: sf_guard_user.id)
        @org.add_extension('School')
        @params = { id: @org.id,
                    entity: { 'extension_def_ids' => '' },
                    reference: { 'source' => 'http://example.com', 'name' => 'new reference' } }
      end
      
      it 'should remove one extension records' do
        expect { patch :update, @params }.to change { ExtensionRecord.count }.by(-1)
      end

      it 'should remove School model' do
        expect { patch :update, @params }.to change { School.count }.by(-1)
      end
      
      it 'redirects to legacy url' do
        patch :update, @params
        expect(response).to redirect_to(@org.legacy_url)
      end
    end

    describe 'updating an Org with errors' do
      let(:org)  { create(:org, last_user_id: sf_guard_user.id) }
      let(:params) { { id: org.id, entity: { 'end_date' => 'bad date' }, reference: {'just_cleaning_up' => '1'} } }
      
      it 'does not change the end_date' do
        expect { patch :update, params }.not_to change { Entity.find(org.id).end_date } 
      end

      it 'renders edit page' do
        patch :update, params
        expect(response).to render_template('edit')
      end
    end
    
    describe 'updating a person with a first name that is too long' do
      let(:person) { create(:person) }
      let(:params) { { id: person.id,
                       entity: { 'blurb' => 'new blurb',
                                 'person_attributes' => { 'name_first' => "#{'x' * 51}", 
                                                          'id' => person.person.id } },
                       reference: { 'reference_id' => '123'} } }
      
      it 'does not change the first name' do
        expect { patch :update, params }.not_to change { Entity.find(person.id).person.name_first } 
      end

      it 'does not change the entity\'s blurb' do
        expect { patch :update, params }.not_to change { Entity.find(person.id).blurb } 
      end

      it 'renders edit page' do
        patch :update, params
        expect(response).to render_template('edit')
      end
    end

    describe 'updating a public company' do
      before do
        @org = create(:org)
        @org.add_extension('PublicCompany', {ticker: 'XYZ'} )
        @params = { id: @org.id,
                    entity: {
                      name: @org.name,
                      public_company_attributes: {
                        id: @org.public_company.id,
                        ticker: 'ABC'
                      }
                    },
                    reference: { 'source' => 'http://example.com', 'name' => 'new reference' } }
      end
      
      it 'updates ticker' do
        expect(Entity.find(@org.id).public_company.ticker).to eq 'XYZ'
        expect { patch :update, @params }.to change { PublicCompany.find(@org.public_company.id).ticker }.to('ABC')
      end

      it 'redirects to legacy url' do
        patch :update, @params
        expect(response).to redirect_to(@org.legacy_url)
      end
    end
  end # end describe #update

  describe 'GET /references' do
    before do
      @entity = build(:mega_corp_inc, updated_at: Time.now, id: rand(100))
      expect(Entity).to receive(:find).with(@entity.id.to_s).and_return(@entity)
      refs = [build(:entity_ref, object_id: @entity.id), build(:entity_ref, object_id: @entity.id) ]
      expect(@entity).to receive(:all_references).and_return(refs)
      expect(Kaminari).to receive(:paginate_array).with(refs).and_return(spy('kaminari'))
      get :references, id: @entity.id
    end
    
    it { should respond_with(200) }
    it { should render_template(:references) }
    
  end
end
