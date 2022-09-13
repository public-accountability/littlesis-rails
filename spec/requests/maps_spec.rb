describe 'Maps', :sphinx, type: :request do
  describe 'redirecting legacy map urls' do
    let(:map) { create(:network_map, user: create(:user)) }

    it 'redirects to oligrapher#show' do
      get "/maps/#{map.id}-so-many-connections"
      expect(response).to have_http_status :moved_permanently
      expect(response['location']).to include "/oligrapher/#{map.id}-so-many-connections"
    end

    it 'redirects to oligrapher#embedded' do
      get "/maps/#{map.id}-so-many-connections/embedded/v2"
      expect(response).to have_http_status :moved_permanently
      expect(response['location']).to include "/oligrapher/#{map.id}-so-many-connections/embedded"
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
        before { get '/oligrapher/find_nodes' }

        specify { expect(response).to have_http_status 400 }
      end

      describe 'searching for "apple"' do
        before { get '/oligrapher/find_nodes', params: { q: 'apple' } }

        it 'finds one entity and returns search results as json' do
          expect(response).to have_http_status 200
          expect(json.length).to eq 1
          expect(json.first.symbolize_keys).to eq Oligrapher::Node.from_entity(@apple_corp)
        end
      end

      describe 'searching for "banana!"' do
        before { get '/oligrapher/find_nodes', params: { q: 'banana!' } }

        it 'finds one entity and returns search results as json' do
          expect(response).to have_http_status 200
          expect(json.length).to eq 1
          expect(json.first.symbolize_keys).to eq Oligrapher::Node.from_entity(@banana_corp)
        end
      end
    end
  end
end
