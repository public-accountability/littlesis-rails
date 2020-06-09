describe SearchController, type: :controller do
  it { is_expected.to route(:get, '/search').to(action: :basic) }
  it { is_expected.to route(:get, '/search/entity').to(action: :entity_search) }

  describe "GET #entity_search" do
    login_user
    let(:org) { build(:org) }

    def search_service_double
      instance_double('EntitySearchService').tap do |d|
        d.instance_variable_set(:@search, [org])
      end
    end

    it 'returns http status bad_request if missing param q' do
      get :entity_search
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http success" do
      allow(Entity).to receive(:search).with("@(name,aliases) name", any_args).and_return([org])
      get :entity_search, params: { :q => 'name' }
      expect(response).to have_http_status(:success)
    end

    it "hash includes url by default" do
      allow(Entity).to receive(:search).with("@(name,aliases) name", any_args).and_return([org])
      get :entity_search, params: { :q => 'name' }
      expect(JSON.parse(response.body)[0]['url']).to include "/org/#{org.id}"
      expect(JSON.parse(response.body)[0]).not_to have_key "is_parent"
    end

    it "hash can optionally include parent" do
      allow(Entity).to receive(:search).with("@(name,aliases) name", any_args).and_return([org])
      expect(org).to receive(:parent?).once.and_return(false)
      get :entity_search, params: { :q => 'name', include_parent: true }
      expect(JSON.parse(response.body)[0]['is_parent']).to eq false
    end
  end
end
