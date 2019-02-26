require 'rails_helper'

describe 'ExternalDatasets requests', type: :request  do
  describe 'row' do
    let(:row) { build_stubbed(:external_dataset) }

    it 'returns row data for dataset' do
      expect(ExternalDataset).to receive(:find).with(row.id.to_s).and_return(row)
      get "/external_datasets/row/#{row.id}"
      expect(response).to have_http_status :ok
      expect(json).to eq row.row_data
    end
  end
end
