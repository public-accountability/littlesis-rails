require 'rails_helper'

describe EntityNetworkMapCollection do
  describe 'initialize' do
    let(:org) { build(:org) }

    context 'no cache exists' do
      it 'sets @maps to be an empty set' do
        expect(EntityNetworkMapCollection.new(org).maps)
          .to eql Set.new
      end
    end

    context 'with an existing set in the cache' do
      before do
        Rails.cache.write("entity-#{org.id}/networkmaps", Set[1, 2, 3])
      end

      it 'reads existing set from cache' do
        expect(EntityNetworkMapCollection.new(org).maps)
          .to eql Set[1, 2, 3]
      end
    end

    it 'delegates methods to the set' do
      entity_network_map_collection = EntityNetworkMapCollection.new(org)
      %i[each map size sort].each do |method|
        expect(entity_network_map_collection).to respond_to method
      end
    end

  end

  describe 'add'

  describe 'remove'

  describe 'delete'

  describe 'save'
end
