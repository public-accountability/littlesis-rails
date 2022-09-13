describe UpdateEntityNetworkMapCollectionsJob, type: :job do
  include ActiveJob::TestHelper

  before do
    EntityNetworkMapCollection.remove_all
  end

  after do
    EntityNetworkMapCollection.remove_all
  end

  let(:e1) { create(:entity_org) }
  let(:e2) { create(:entity_org) }

  let(:nodes) do
    { e1.id => Oligrapher::Node.from_entity(e1),
      e2.id => Oligrapher::Node.from_entity(e2) }
  end

  let(:graph_data) do
    JSON.dump(id: 'abcdefg', nodes: nodes, edges: {}, captions: {})
  end

  let(:graph_data_missing_node_two) do
    JSON.dump(id: 'abcdefg',
              nodes: { e1.id => Oligrapher::Node.from_entity(e1) },
              edges: {}, captions: {})
  end

  let(:network_map) { create(:network_map, user_id: 1) }

  def assert_network_map_collection_equals(entity, set)
    expect(EntityNetworkMapCollection.new(entity).maps).to eq set
  end

  it 'adds id for all entities' do
    assert_network_map_collection_equals e1, Set.new
    assert_network_map_collection_equals e2, Set.new
    network_map.graph_data = graph_data
    network_map.save!
    perform_enqueued_jobs
    assert_network_map_collection_equals e1, [network_map.id].to_set
    assert_network_map_collection_equals e2, [network_map.id].to_set
  end

  it 'when an entity is removed, it removes it from the associated entity' do
    network_map.graph_data = graph_data
    network_map.save!
    perform_enqueued_jobs
    assert_network_map_collection_equals e2, [network_map.id].to_set
    network_map.graph_data = graph_data_missing_node_two
    network_map.save!
    perform_enqueued_jobs
    assert_network_map_collection_equals e2, Set.new
  end

  it 'removes from all collection after network map is soft deleted' do
    network_map.graph_data = graph_data
    network_map.save!
    perform_enqueued_jobs
    assert_network_map_collection_equals e1, [network_map.id].to_set
    assert_network_map_collection_equals e2, [network_map.id].to_set
    network_map.soft_delete
    perform_enqueued_jobs
    assert_network_map_collection_equals e1, Set.new
    assert_network_map_collection_equals e2, Set.new
  end
end
