require 'rails_helper'

describe 'ExternalDatasets requests', type: :request  do
  let(:row) { build_stubbed(:external_dataset) }

  def mock_external_dataset_find
    expect(ExternalDataset).to receive(:find).with(row.id.to_s).and_return(row)
  end

  describe 'row' do
    it 'returns row data for dataset' do
      mock_external_dataset_find
      get "/external_datasets/row/#{row.id}"
      expect(response).to have_http_status :ok
      expect(json.except('updated_at', 'created_at')).to eq row.as_json.except('updated_at', 'created_at')
    end
  end

  describe 'POST #match' do
    it 'raises error if missing entity id' do
      post "/external_datasets/row/#{row.id}/match"
      expect(response).to have_http_status :bad_request
    end

    it 'raises error if entity id is not a number' do
      post "/external_datasets/row/#{row.id}/match", params: { "entity_id" => 'abc' }
      expect(response).to have_http_status :bad_request
    end
  end
end
