require 'rails_helper'

describe UpdateEntityNetworkMapCollectionsJob, type: :job do
  include ActiveJob::TestHelper
  let(:e1) { create(:entity_org) }
  let(:e2) { create(:entity_org) }

  let(:nodes) do
    { e1.id => Oligrapher.entity_to_node(e1),
      e2.id => Oligrapher.entity_to_node(e2) }
  end

  let(:graph_data) do
    JSON.dump(id: 'abcdefg', nodes: nodes, edges: {}, captions: {})
  end

  let(:graph_data_missing_node_two) do
    JSON.dump(id: 'abcdefg',
              nodes: { e1.id => Oligrapher.entity_to_node(e1) },
              edges: {}, captions: {})
  end

  let(:network_map) { create(:network_map, user_id: 1) }

  it 'adds id for all entities' do
    [e1, e2].each do |entity|
      expect(EntityNetworkMapCollection.new(entity).maps).to eql Set.new
    end

    network_map.graph_data = graph_data
    perform_enqueued_jobs { network_map.save! }

    [e1, e2].each do |entity|
      expect(EntityNetworkMapCollection.new(entity).maps).to eql [network_map.id].to_set
    end
  end

  it 'when an entity is removed, it removes it from the associated entity' do
    network_map.graph_data = graph_data
    perform_enqueued_jobs { network_map.save! }
    expect(EntityNetworkMapCollection.new(e2).maps).to eql [network_map.id].to_set
    network_map.graph_data = graph_data_missing_node_two
    perform_enqueued_jobs { network_map.save! }
    expect(EntityNetworkMapCollection.new(e2).maps).to eql Set.new
  end
end
