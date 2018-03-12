require 'rails_helper'

describe 'Maps', :sphinx, type: :request do
  describe 'featuring maps' do
    as_basic_user do
      let(:map) { create(:network_map, user_id: SfGuardUser.last.id) }
      let(:url) { Rails.application.routes.url_helpers.feature_map_path(map) }
      before { post url, params: { action: 'ADD' } }
      denies_access
    end
  end

  describe 'oligrapher search api' do
    before(:all) do
      setup_sphinx 'entity_core' do
        @apple_corp = create(:entity_org, name: 'apple corp')
        @banana_corp = create(:entity_org, name: 'banana! corp')
      end
    end

    after(:all) do
      teardown_sphinx { delete_entity_tables }
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
          expect(json.length).to eql(1)
          expect(ActiveSupport::HashWithIndifferentAccess.new(json.first))
            .to eql ActiveSupport::HashWithIndifferentAccess.new(Oligrapher.entity_to_node(@apple_corp))
        end
      end

      describe 'searching for "banana!"' do
        before { get '/maps/find_nodes', params: { q: 'banana!' } }

        it 'finds one entity and returns search results as json' do
          expect(response).to have_http_status 200
          expect(json.length).to eql(1)
          expect(ActiveSupport::HashWithIndifferentAccess.new(json.first))
            .to eql ActiveSupport::HashWithIndifferentAccess.new(Oligrapher.entity_to_node(@banana_corp))
        end
      end
    end
  end
end
