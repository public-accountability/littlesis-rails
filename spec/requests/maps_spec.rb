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

  describe 'creating new maps' do
    let(:request_params) do
      { title: 'so many connections',
        data: JSON.dump({"entities"=>[], "rels"=>[], "texts"=>[]}),
        graph_data: JSON.dump({"nodes"=>{}, "edges"=>{}, "captions"=>{}}),
        width: 960,
        height: 960,
        annotations_data: [],
        annotations_count: 0,
        is_private: false,
        is_cloneable: true }
    end

    let(:post_maps) do
      -> { post '/maps', params: request_params }
    end

    context 'with anon user' do
      before { post_maps.call }

      redirects_to_login
    end

    context 'with basic user' do
      let(:user) { create_basic_user }

      before { login_as(user, :scope => :user) }

      after { logout(:user) }

      it 'creates a new map' do
        expect(&post_maps).to change(NetworkMap, :count).by(1)
      end

      it 'sets sf_user_id' do
        post_maps.call
        expect(NetworkMap.last.sf_user_id).to eql user.sf_guard_user_id
      end
    end
  end
end
