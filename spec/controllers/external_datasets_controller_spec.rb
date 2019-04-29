require 'rails_helper'

describe ExternalDatasetsController, type: :controller do
  it { is_expected.to route(:get, '/external_datasets').to(action: :index) }
  it { is_expected.to route(:get, '/external_datasets/iapd').to(action: :iapd) }
  it { is_expected.to route(:get, '/external_datasets/row/666').to(action: :row, id: '666') }
  it { is_expected.to route(:get, '/external_datasets/row/666/matches').to(action: :matches, id: '666') }
  it { is_expected.to route(:post,'/external_datasets/row/666/match').to(action: :match, id: '666') }
  it { is_expected.to route(:get, '/external_datasets/row/something').to(action: :not_found, controller: :errors, path: 'external_datasets/row/something') }

  describe 'flows' do
    it { is_expected.to route(:get, '/external_datasets/iapd/flow/advisors/next').to(action: :flow, dataset: 'iapd', flow: 'advisors') }
    it { is_expected.to route(:get, '/external_datasets/iapd/flow/owners/next').to(action: :flow, dataset: 'iapd', flow: 'owners') }
    it { is_expected.to route(:get, '/external_datasets/not_a_dataset/flow/owners/next').to(action: :not_found, controller: :errors, path: 'external_datasets/not_a_dataset/flow/owners/next') }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
