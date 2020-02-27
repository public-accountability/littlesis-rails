require 'rails_helper'

describe "Oligrapher", type: :request do
  let(:user) { create_basic_user }

  describe 'POST /oligrapher' do
    before { login_as(user, scope: :user) }

    after { logout(:user) }

    let(:graph_data) do
      JSON.parse <<-JSON
       {
         "nodes": {
         "EI-H6Mvz": {
           "id": "EI-H6Mvz",
           "name": "abc",
           "x": -72.5,
           "y": -10.5,
           "scale": 1,
           "status": "normal",
           "type": "circle",
           "image": null,
           "url": null,
           "color": "#ccc"
         }
       },
       "edges": {},
       "captions": {}
      }
     JSON
    end

    let(:params) do
      {
        "graph_data" => graph_data,
        "attributes" => {
          "title" => "example title",
          "description" => "example description",
          "is_private" => false,
          "is_cloneable" => true
        }
      }
    end

    it 'creates a new NetworkMap' do
      expect { post '/oligrapher', params: params}.to change(NetworkMap, :count).by(1)
      expect(NetworkMap.last.oligrapher_version).to eq 3
      expect(NetworkMap.last.user_id).to eq user.id
    end

    it 'responds with json' do
      post '/oligrapher', params: params
      expect(response.status).to eq 200
      expect(valid_json?(response.body)).to be true
      expect(JSON.parse(response.body)['id']).to be_a Integer
    end

    it 'renders json of errors if invalid' do
      post '/oligrapher', params: { "graph_data" => graph_data, "attributes" => { "is_private": false } }
      expect(response.status).to eq 400
      expect(valid_json?(response.body)).to be true
      expect(json['title'][0]).to eq "can't be blank"
    end
  end

  describe 'PATCH /oligrapher/:id' do
    let(:user) { create_basic_user }
    let(:network_map) { create(:network_map_version3, user_id: user.id) }

    context 'when logged in' do
      before { login_as(user, scope: :user) }

      after { logout(user) }

      it 'updates title' do
        expect do
          patch "/oligrapher/#{network_map.id}", params: { "attributes" => { "title" => "new title" } }
        end.to change { NetworkMap.find(network_map.id).title }.from("network map").to("new title")
        expect(response.status).to eq 200
      end
    end
  end

  describe 'find_nodes' do
    let(:nodes) do
      [build(:org, :with_org_name), build(:org, :with_org_name)]
    end

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
