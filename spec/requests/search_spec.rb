require 'rails_helper'

describe 'Search', :sphinx, type: :request do
  let(:user) { create_really_basic_user }
  before { login_as(user, :scope => :user) }
  after { logout(:user) }

  describe 'entity_search' do
    before(:all) do
      setup_sphinx 'entity_core' do
        @apple_corp = create(:entity_org, name: 'apple org')
        @apple_person = create(:entity_person, name: 'apple person')
        @banana_corp = create(:entity_org, name: 'banana! corp')
      end
    end

    after(:all) do
      teardown_sphinx { delete_entity_tables }
    end

    describe 'searching by keyword' do
      it 'finds two entities and results json' do
        get '/search/entity', params: { q: 'apple' }
        expect(response).to have_http_status 200
        expect(json.length).to eql 2
        expect(json.map { |e| e['name'] }.to_set).to eql Set['apple org', 'apple person']
      end

      it 'can set limit option' do
        get '/search/entity', params: { q: 'apple', num: '1' }
        expect(response).to have_http_status 200
        expect(json.length).to eql 1
      end
    end

    describe 'Limiting search to person or org' do
      it 'limits results to people' do
        get '/search/entity', params: { q: 'apple', ext: 'Person' }
        expect(response).to have_http_status 200
        expect(json.length).to eql 1
        expect(json.first['name']).to eql 'apple person'
      end

      it 'limits result to org' do
        get '/search/entity', params: { q: 'apple', ext: 'Org' }
        expect(response).to have_http_status 200
        expect(json.length).to eql 1
        expect(json.first['name']).to eql 'apple org'
      end
    end
  end
end
