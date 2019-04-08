require 'rails_helper'

describe SearchController, type: :controller do
  it { is_expected.to route(:get, '/search').to(action: :basic) }
  it { is_expected.to route(:get, '/search/entity').to(action: :entity_search) }

  describe "GET #entity_search" do
    login_user
    let(:org) { build(:org) }

    def search_service_double
      instance_double('EntitySearchService').tap do |d|
        allow(d).to receive(:search).and_return([org])
      end
    end

    it 'returns http status bad_request if missing param q' do
      get :entity_search
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http success" do
      allow(EntitySearchService).to receive(:new).and_return(search_service_double)
      get :entity_search, params: { :q => 'name' }
      expect(response).to have_http_status(:success)
    end

    it "calls search with query param and returns complete hash by default" do
      expect(EntitySearchService).to receive(:new).with(query: 'name').and_return(search_service_double)
      expect(org).to receive(:to_hash).once
      get :entity_search, params: { :q => 'name' }
    end

    it "returns simplier hash if param return_type=simple is submitted with request" do
      expect(EntitySearchService).to receive(:new).with(query: 'name').and_return(search_service_double)
      expect(EntitySearchService).to receive(:simple_entity_hash).once.and_call_original
      get :entity_search, params: { :q => 'name', :return_type => 'simple' }
    end
  end
end
