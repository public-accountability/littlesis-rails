require 'rails_helper'

describe "Oligrapher", type: :request do
  let(:nodes) do
    [build(:org, :with_org_name), build(:org, :with_org_name)]
  end

  describe 'find_nodes' do
    it 'responds with bad request if missing query' do
      get '/oligrapher/find_nodes', params: {}
      expect(response).to have_http_status 400
    end

    it 'renders json' do
      expect(EntitySearchService).to receive(:new)
                                       .once
                                       .with(query: 'abc',
                                             fields: %w[name aliases blurb],
                                             per_page: 5)
                                       .and_return(double(:search => nodes))

      get '/oligrapher/find_nodes', params: { q: 'abc', num: '5' }

      expect(response).to have_http_status 200
      expect(json.length).to eq 2
    end
  end
end
