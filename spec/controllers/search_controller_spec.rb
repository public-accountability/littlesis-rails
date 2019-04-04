require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  it { is_expected.to route(:get, '/search').to(action: :basic) }
  it { is_expected.to route(:get, '/search/entity').to(action: :entity_search) }

  describe "GET #entity_search" do
    login_user

    def search_service_double
      instance_double('EntitySearchService').tap do |d|
        allow(d).to receive(:search).and_return([build(:org)])
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

    it "calls search with query param and returns results with summary by default" do
      expect(EntitySearchService).to receive(:new).with(query: 'name').and_return(search_service_double)
      expect(Entity::Search).to receive(:entity_with_summary).once.and_call_original
      get :entity_search, params: { :q => 'name' }
    end

    it "it removes summary if param 'no_summary' is submitted with request" do
      expect(EntitySearchService).to receive(:new).with(query: 'name').and_return(search_service_double)
      expect(Entity::Search).to receive(:entity_no_summary).once.and_call_original
      get :entity_search, params: { :q => 'name', :no_summary => 'true' }
    end
  end
end
