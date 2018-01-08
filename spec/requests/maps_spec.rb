require 'rails_helper'

describe 'Maps', type: :request do
  before(:all) do
    ThinkingSphinx::Deltas.suspend!
    @apple_corp = create(:entity_org, name: 'apple corp')
    @banana_crop = create(:entity_org, name: 'banana! corp')
    ThinkingSphinx::Test.init
    ThinkingSphinx::Test.index 'entity_core'
    ThinkingSphinx::Test.start index: false
  end

  after(:all) do
    ThinkingSphinx::Test.stop
    ThinkingSphinx::Test.clear
    Entity.delete_all
    Link.delete_all
    Alias.delete_all
    ThinkingSphinx::Deltas.resume!
  end

  describe 'find nodes' do
    describe 'searching for "apple"' do
      before { get '/maps/find_nodes', params: { q: 'apple' } }

      it 'returns finds one entity and returns search results as json' do
        expect(response).to have_http_status 200
        expect(json.length).to eql(1)
        expect(ActiveSupport::HashWithIndifferentAccess.new(json.first))
          .to eql ActiveSupport::HashWithIndifferentAccess.new(Oligrapher.entity_to_node(@apple_corp))
      end
    end

    describe 'searching for "banana!"' do
      before { get '/maps/find_nodes', params: { q: 'banana!' } }

      it 'returns finds one entity and returns search results as json' do
        expect(response).to have_http_status 200
        expect(json.length).to eql(1)
        expect(ActiveSupport::HashWithIndifferentAccess.new(json.first))
          .to eql ActiveSupport::HashWithIndifferentAccess.new(Oligrapher.entity_to_node(@banana_corp))
      end
    end
  end
end
