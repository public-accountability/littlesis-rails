require 'rails_helper'

describe EntityNetworkMapCollection do
  let(:org) { build(:org) }
  subject { EntityNetworkMapCollection.new(org) }

  describe 'initialize' do
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
      %i[each map size sort empty?].each do |method|
        expect(entity_network_map_collection).to respond_to method
      end
    end

  end

  describe 'add' do
    it 'adds the id to the set' do
      expect(subject.maps).to eql Set.new
      subject.add(7)
      expect(subject.maps).to eql [7].to_set
    end
  end

  describe 'remove' do
    before do
      Rails.cache.write("entity-#{org.id}/networkmaps", Set[1, 2, 3])
    end

    it 'removes the id from the set' do
      expect(subject.maps).to eql Set[1, 2, 3]
      subject.remove(2)
      expect(subject.maps).to eql [1, 3].to_set
    end
  end

  describe 'delete' do
    before do
      Rails.cache.write("entity-#{org.id}/networkmaps", Set[1, 2, 3])
    end

    it 'deletes the set from the cache' do
      expect(subject.maps).to eql Set[1, 2, 3]
      subject.delete
      expect(subject.maps).to eql Set.new
      expect(Rails.cache.exist?("entity-#{org.id}/networkmaps")).to be false
    end
  end

  describe 'save' do
    it 'persists changes to the cache' do
      expect(subject.maps).to eql Set.new
      expect(Rails.cache.exist?("entity-#{org.id}/networkmaps")).to be false
      subject.add(7)
      expect(subject.maps).to eql [7].to_set
      expect { subject.save }
        .to change { Rails.cache.exist?("entity-#{org.id}/networkmaps") }
              .from(false).to(true)
      expect(Rails.cache.read("entity-#{org.id}/networkmaps")).to eql [7].to_set
    end

    it 'saving an empty set, deletes the cache' do
      subject.add(7).save
      expect(Rails.cache.exist?("entity-#{org.id}/networkmaps")).to be true
      subject.remove(7).save
      expect(Rails.cache.exist?("entity-#{org.id}/networkmaps")).to be false
    end
  end
end
