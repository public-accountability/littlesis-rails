require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  it { should route(:get, '/search').to(action: :basic) }
  it { should route(:get, '/search/entity').to(action: :entity_search) }

  describe "GET #entity_search" do
    login_user

    it 'returns http status bad_request if missing param q' do
      get :entity_search
      expect(response).to have_http_status(:bad_request)
    end

    it "returns http success" do
      allow(Entity::Search).to receive(:search).and_return([build(:org)])
      get :entity_search, :q => 'name'
      expect(response).to have_http_status(:success)
    end

    it "calls search with query param and returns results with summary by default" do
      expect(Entity::Search).to receive(:search).with('name', kind_of(Hash)).and_return([build(:org)])
      expect(Entity::Search).to receive(:entity_with_summary).once.and_call_original
      get :entity_search, :q => 'name'
    end

    it "it removes summary if param 'no_summary' is submitted with request" do
      expect(Entity::Search).to receive(:search).with('name', kind_of(Hash)).and_return([build(:org)])
      expect(Entity::Search).to receive(:entity_no_summary).once.and_call_original
      get :entity_search, :q => 'name', :no_summary => 'true'
    end
  end
end


