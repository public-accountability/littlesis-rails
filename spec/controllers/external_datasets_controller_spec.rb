describe ExternalDatasetsController, type: :controller do
  it { is_expected.to route(:get, '/external_datasets').to(action: :index) }
  it { is_expected.to route(:get, '/external_datasets/iapd').to(action: :iapd) }
  it { is_expected.to route(:get, '/external_datasets/row/666').to(action: :row, id: '666') }
  it { is_expected.to route(:get, '/external_datasets/row/666/matches').to(action: :matches, id: '666') }
  it { is_expected.to route(:post,'/external_datasets/row/666/match').to(action: :match, id: '666') }
  it { is_expected.to route(:get, '/external_datasets/row/something').to(action: :not_found, controller: :errors, path: 'external_datasets/row/something') }
  it { is_expected.to route(:get, '/external_datasets/iapd/search').to(action: :search, dataset: 'iapd') }
  it { is_expected.to route(:post, '/external_datasets/iapd/search').to(action: :search, dataset: 'iapd') }

  describe 'flows' do
    it { is_expected.to route(:get, '/external_datasets/iapd/flow/advisors/next').to(action: :flow, dataset: 'iapd', flow: 'advisors') }
    it { is_expected.to route(:get, '/external_datasets/iapd/flow/owners/next').to(action: :flow, dataset: 'iapd', flow: 'owners') }
    it { is_expected.to route(:get, '/external_datasets/not_a_dataset/flow/owners/next').to(action: :not_found, controller: :errors, path: 'external_datasets/not_a_dataset/flow/owners/next') }
  end

  describe 'GET #index' do
    before { allow(controller).to receive(:authenticate_user!) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'matching' do
    before { allow(controller).to receive(:authenticate_user!) }

    let(:row_id) { Faker::Number.number }
    let(:entity_id) { Faker::Number.number }
    let(:entity) { instance_double('Entity') }
    let(:row) { instance_double('ExternalDataset', id: row_id) }
    let(:match_with_double) { double(result: :owner_not_found) }

    context 'when the row does not exist' do
      specify do
        allow(Entity).to receive(:find).with(entity_id).and_return(entity)
        expect(ExternalDataset).to receive(:find).with(row_id).and_raise(ActiveRecord::RecordNotFound)
        get :match, params: { id: row_id, entity_id: entity_id }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the entity id is not a number' do
      specify do
        get :match, params: { id: row_id, entity_id: 'one' }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the match is successful' do
      specify do
        expect(ExternalDataset).to receive(:find).with(row_id).and_return(row)
        expect(Entity).to receive(:find).with(entity_id).and_return(entity)
        expect(row).to receive(:match_with).with(entity).and_return([match_with_double])
        expect(row).to receive(:matched?).once.and_return(true)
        expect(entity).to receive(:to_hash).and_return('id' => entity_id, 'name' => 'abc')

        get :match, params: { id: row_id, entity_id: entity_id }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq('status' => 'matched',
                                                'results' => ['owner_not_found'],
                                                'entity' => { 'id' => entity_id, 'name' => 'abc' })
      end
    end

    context 'when the match fails' do
      specify do
        expect(ExternalDataset).to receive(:find).with(row_id).and_return(row)
        expect(Entity).to receive(:find).with(entity_id).and_return(entity)
        expect(row).to receive(:match_with).with(entity).and_return([match_with_double])
        expect(row).to receive(:matched?).once.and_return(false)

        get :match, params: { id: row_id, entity_id: entity_id }
        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)).to eq('status' => 'error',
                                                'error' => "Failed to save match for row #{row_id}")
      end
    end

    context 'when the row is already matched' do
      specify do
        expect(ExternalDataset).to receive(:find).with(row_id).and_return(row)
        expect(Entity).to receive(:find).with(entity_id).and_return(entity)
        expect(row).to receive(:match_with).with(entity).and_raise(ExternalDataset::RowAlreadyMatched)
        get :match, params: { id: row_id, entity_id: entity_id }
        expect(response).to have_http_status(:conflict)
        expect(JSON.parse(response.body)).to eq('status' => 'error',
                                                'error' => "Row #{row_id} is already matched")
      end
    end
  end
end
