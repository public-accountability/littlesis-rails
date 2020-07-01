describe NYSController, type: :controller do
  before do
    Entity.skip_callback(:create, :after, :create_primary_ext)
    ActiveJob::Base.queue_adapter = :test
    DatabaseCleaner.start
  end

  after do
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end

  describe 'routes' do
    it { is_expected.to route(:get, '/nys').to(action: :index) }
    it { is_expected.to route(:post, '/nys/match_donations').to(action: :match_donations) }
    it { is_expected.to route(:post, '/nys/unmatch_donations').to(action: :unmatch_donations) }
    it { is_expected.to route(:get, '/nys/candidates').to(action: :candidates) }
    it { is_expected.to route(:get, '/nys/candidates/new').to(action: :new_filer_entity, type: 'candidates') }
    it { is_expected.to route(:get, '/nys/pacs/new').to(action: :new_filer_entity, type: 'pacs') }
    it { is_expected.to route(:post, '/nys/candidates/new').to(action: :create, type: 'candidates') }
    it { is_expected.to route(:post, '/nys/ny_filer_entity').to(action: :create_ny_filer_entity) }
    it { is_expected.to route(:post, '/nys/pacs/new').to(action: :create, type: 'pacs') }
    it { is_expected.to route(:get, '/nys/potential_contributions').to(action: :potential_contributions) }
    it { is_expected.to route(:get, '/nys/contributions').to(action: :contributions) }
    it { is_expected.to route(:get, '/nys/pacs').to(action: :pacs) }
  end

  describe 'pages' do
    login_user
    describe 'candidates' do
      before { get :candidates }

      it { is_expected.to respond_with(200) }
      it { is_expected.to render_template(:candidates) }
    end

    describe 'pacs' do
      before { get :pacs }

      it { is_expected.to respond_with(200) }
      it { is_expected.to render_template(:pacs) }
    end

    describe 'index' do
      before { get :index }

      it { is_expected.to respond_with(200) }
      it { is_expected.to render_template(:index) }
    end
  end

  describe '#potential_contributions' do
    login_user %i[edit bulk]

    let(:search_options) do
      {
        with: {
          is_matched: false,
          transaction_code: %w[A B C]
        },
        sql: {
          include: :ny_filer
        },
        per_page: 500
      }
    end

    it 'returns 200' do
      person = build(:person, id: 12_345, name: 'big donor')
      expect(person).to receive(:aliases).and_return([double(:name => 'Big Donor')])
      disclosure = double('NyDisclosure')
      expect(disclosure).to receive(:map)
      expect(Entity).to receive(:find).with(12_345).and_return(person)
      expect(NyDisclosure).to receive(:search)
                               .with('Big Donor', **search_options)
                               .and_return(disclosure)
      get :potential_contributions, params: { entity: '12345' }
      expect(response.status).to eq(200)
    end
  end

  describe '#match_donations' do
    login_user %i[edit bulk]

    it 'Matches provides ids' do
      expect(NyMatch).to receive(:match).with('12', '666', kind_of(Numeric))
      expect(NyMatch).to receive(:match).with('17', '666', kind_of(Numeric))
      post :match_donations, params: { payload: { disclosure_ids: [12, 17], donor_id: '666' } }
    end

    describe 'thinking sphinx:' do
      before { @disclosure = create(:ny_disclosure) }

      it 'Updates delta on ny disclosure' do
        allow(NyMatch).to receive(:match)
        expect(NyDisclosure).to receive(:update_delta_flag).with(['12', '17'])
        post :match_donations, params: { payload: { disclosure_ids: [12, 17], donor_id: '666' } }
      end

      # it 'enques delayed_delta job' do
      #   allow(NyMatch).to receive(:match)
      #   expect { post(:match_donations, {payload: {disclosure_ids: [@disclosure.id], donor_id: '666'}}) }
      #     .to have_enqueued_job.on_queue('delta')
      # end
    end

    it 'creates new matches' do
      person = create(:person, name: 'big donor')
      disclosure = create(:ny_disclosure)
      count = NyMatch.count
      post :match_donations,
           params: { payload: { disclosure_ids: [disclosure.id], donor_id: person.id } }
      expect(NyMatch.count).to eql(count + 1)
    end

    it 'changes updated_at field' do
      person = create(:person, name: "big donor")
      person.update_column(:updated_at, 1.day.ago)
      allow(NyMatch).to receive(:match)
      post :match_donations, params: { payload: { disclosure_ids: [1], donor_id: person.id } }
      expect(Entity.find(person.id).updated_at > person.updated_at).to be true
    end
  end

  describe '#create' do
    login_user %i[edit bulk]

    before do
      ny_filer = build(:ny_filer, filer_id: "C9")
      expect(NyFilerEntity).to receive(:create!)
                                 .with(entity_id: '123', ny_filer_id: '10', filer_id: 'C9')
      expect(NyFilerEntity).to receive(:create!)
                                 .with(entity_id: '123', ny_filer_id: '11', filer_id: 'C9')
      expect(NyFiler).to receive(:find).with('10').and_return(ny_filer)
      expect(NyFiler).to receive(:find).with('11').and_return(ny_filer)
      entity = double('entity')
      expect(entity).to receive(:update).with(hash_including(:last_user_id => controller.current_user.id))
      expect(Entity).to receive(:find).with('123').and_return(entity)
    end

    it 'Handles POST' do
      post(:create, params: { entity: '123', ids: %w[10 11], type: 'candidates' })
      expect(response.status).to eq 302
    end
  end

  describe "#new_filer_entity" do
    login_user

    context 'default search' do
      before do
        elected = build(:elected, id: 123)
        expect(elected).to receive(:person).and_return(double(:name_last => 'elected'))
        expect(NyFiler).to receive(:search_filers).with("elected").and_return([])
        expect(Entity).to receive(:find).and_return(elected)
      end

      it 'Handles GET' do
        get :new_filer_entity, params: { entity: '123', type: 'candidates' }
        expect(response.status).to eq(200)
        expect(response).to render_template(:new_filer_entity)
      end
    end

    context 'with custom query' do
      it 'searches for custom query' do
        elected = build(:elected, id: 123)
        expect(NyFiler).to receive(:search_filers).with("my custom search").and_return([])
        expect(Entity).to receive(:find).and_return(elected)
        get :new_filer_entity,
            params: { entity: '123', query: 'my custom search', type: 'candidates' }
        expect(response.status).to eq(200)
        expect(response).to render_template(:new_filer_entity)
      end
    end

    context 'if entity is an org' do
      before do
        pac = build(:pac, id: 666)
        expect(NyFiler).to receive(:search_pacs).with('PAC').and_return([])
        expect(Entity).to receive(:find).with('666').and_return(pac)
        get :new_filer_entity, params: { entity: '666', type: 'pacs' }
      end

      it 'responds with 200 and renders new_filer_entity template' do
        expect(response.status).to eq(200)
        expect(response).to render_template(:new_filer_entity)
      end
    end
  end
end
