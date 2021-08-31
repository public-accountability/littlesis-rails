describe 'Maps', :sphinx, type: :request do
  describe 'redirecting version 3 map' do
    let(:map) { create(:network_map, user: create(:user), oligrapher_version: 3) }

    before { get "/maps/#{map.id}-so-many-connections" }

    it 'redirects to oligrapher#show' do
      expect(response).to redirect_to oligrapher_path(map)
    end
  end

  describe 'featuring maps' do
    as_basic_user do
      let(:map) { create(:network_map, user_id: User.last.id) }
      let(:url) { Rails.application.routes.url_helpers.feature_map_path(map) }
      before { post url, params: { action: 'ADD' } }

      specify { expect(response).to have_http_status :not_found }
    end
  end

  describe 'oligrapher search api' do
    before do
      setup_sphinx
      @apple_corp = create(:entity_org, name: 'apple corp')
      @banana_corp = create(:entity_org, name: 'banana! corp')
    end

    after do
      teardown_sphinx
    end

    describe 'find nodes' do
      describe 'missing param q' do
        before { get '/maps/find_nodes' }

        specify { expect(response).to have_http_status 400 }
      end

      describe 'searching for "apple"' do
        before { get '/maps/find_nodes', params: { q: 'apple' } }

        it 'finds one entity and returns search results as json' do
          expect(response).to have_http_status 200
          expect(json.length).to eq 1
          expect(json.first.with_indifferent_access)
            .to eq Oligrapher.legacy_entity_to_node(@apple_corp).with_indifferent_access
        end
      end

      describe 'searching for "banana!"' do
        before { get '/maps/find_nodes', params: { q: 'banana!' } }

        it 'finds one entity and returns search results as json' do
          expect(response).to have_http_status 200
          expect(json.length).to eq 1
          expect(json.first.with_indifferent_access)
            .to eq Oligrapher.legacy_entity_to_node(@banana_corp).with_indifferent_access
        end
      end
    end
  end
end
