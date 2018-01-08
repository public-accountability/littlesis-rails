require 'rails_helper'

describe 'Maps', type: :request do
  before(:all) do
    ThinkingSphinx::Deltas.suspend!
    DatabaseCleaner.strategy = :deletion
  end

  after(:all) do
    ThinkingSphinx::Deltas.resume!
    DatabaseCleaner.strategy = :transaction
  end

  describe 'find nodes' do
    let!(:apple_corp) { create(:entity_org, name: 'apple corp') }
    let!(:banana_corp) { create(:entity_org, name: 'banana! corp') }

    before do
      ThinkingSphinx::Test.init
      ThinkingSphinx::Test.index 'entity_core'
      ThinkingSphinx::Test.start index: false
    end

    after do
      ThinkingSphinx::Test.stop
      ThinkingSphinx::Test.clear
    end

    describe 'searching for "apple"' do
      before { get '/maps/find_nodes', params: { q: 'apple' } }

      it 'returns finds one entity and returns search results as json' do
        expect(response).to have_http_status 200
        expect(json.length).to eql(1)
        expect(ActiveSupport::HashWithIndifferentAccess.new(json.first))
          .to eq(ActiveSupport::HashWithIndifferentAccess.new(Oligrapher.entity_to_node(apple_corp)))
      end
    end

    describe 'searching for "banana!"' do
      before { get '/maps/find_nodes', params: { q: 'banana!' } }

      it 'returns finds one entity and returns search results as json' do
        expect(response).to have_http_status 200
        expect(json.length).to eql(1)
        expect(ActiveSupport::HashWithIndifferentAccess.new(json.first))
          .to eq(ActiveSupport::HashWithIndifferentAccess.new(Oligrapher.entity_to_node(banana_corp)))
      end
    end
  end
end
