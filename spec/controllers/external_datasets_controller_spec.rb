require 'rails_helper'

describe ExternalDatasetsController, type: :controller do
  it { is_expected.to route(:get, '/external_datasets').to(action: :index) }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
