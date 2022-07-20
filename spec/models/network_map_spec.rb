# frozen_string_literals: true

describe NetworkMap, type: :model do
  let(:graph_data) do
    JSON.parse <<-JSON
       {
         "nodes": {
           "EI-H6Mvz": {
             "id": "EI-H6Mvz",
             "name": "abc",
             "x": -72.5,
             "y": -10.5,
             "scale": 1,
             "status": "normal",
             "type": "circle",
             "image": null,
             "url": null,
             "color": "#ccc"
           }
         },
         "edges": {},
         "captions": {}
       }
    JSON
  end

  it { is_expected.to have_db_column(:editors) }
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to validate_presence_of(:title) }

  describe 'sets defaults' do
    let(:network_map) { create(:network_map, user_id: 1) }

    specify do
      expect(network_map.oligrapher_commit).to eq Rails.application.config.littlesis.oligrapher_commit
    end
  end

  describe '#documents' do
    let(:relationships) do
      Array.new(2) do
        Relationship.create!(category_id: 12, entity: create(:entity_org), related: create(:entity_person))
      end
    end

    let(:edges) do
      { relationships[0].id => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
        relationships[1].id => { id: 123, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } } }
    end

    let(:graph_data) do
      OligrapherGraphData.new(id: 'xyz', nodes: {}, captions: {}, edges: edges)
    end
    let(:urls) { Array.new(2) { Faker::Internet.unique.url } }
    let(:map) { build(:network_map, graph_data: graph_data) }

    it 'returns uniq set of documents' do
      # The relationships should have 3 references, with 2 uniq urls
      relationships.first.add_reference(url: urls[0], name: Faker::Lorem.sentence)
      relationships.second.add_reference(url: urls[0], name: Faker::Lorem.sentence)
      relationships.second.add_reference(url: urls[1], name: Faker::Lorem.sentence)

      expect(map.documents.to_set)
        .to eql([Document.find_by(url: urls.first), Document.find_by(url: urls.second)].to_set)
    end
  end

  describe 'documents_to_html' do
    let(:documents) { Array.new(2) { build(:document) } }
    let(:map) do
      build(:network_map).tap { |m| expect(m).to receive(:documents).and_return(documents) }
    end

    it 'returns array of html' do
      html = ['<div><a href="' + documents[0].url + '">' + documents[0].name + '</a></div>',
              '<div><a href="' + documents[1].url + '">' + documents[1].name + '</a></div>'].join("\n")
      expect(map.documents_to_html).to eql(html)
    end
  end

  describe 'rels' do
    let(:edges) do
      { '123' => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
        '456' => { id: 123, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } } }
    end
    let(:graph_data) do
      OligrapherGraphData.new(id: 'xyz', nodes: {}, captions: {}, edges: edges)
    end
    let(:map) { build(:network_map, graph_data: graph_data) }

    it 'retrives relationship from graph data' do
      expect(Relationship).to receive(:where).with(id: ['123', '456'])
      map.rels
    end
  end

  describe 'edge_ids' do
    let(:graph_data) do
      OligrapherGraphData.new(id: 'NkpdQPQfx',
                nodes: {},
                edges: {
                  '1' => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
                  '2' => { id: 2, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } }
                },
                captions: { '1' => { id: 1, display: { text: "Caption 1" } } })
    end

    let(:map) { build(:network_map, graph_data: graph_data) }

    it 'returns list of ids' do
      expect(Set.new(map.edge_ids(map.graph_data))).to eql ['1', '2'].to_set
    end
  end

  describe 'numeric edge ids' do
    let(:edges) { {} }
    let(:graph_data) do
      OligrapherGraphData.new(id: 'xyz', nodes: {}, captions: {}, edges: edges)
    end
    let(:map) { build(:network_map, graph_data: graph_data) }

    context 'with no numberic ids' do
      let(:edges) do
        { 'HywTymBnW' => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
          'BkVslmr2-' => { id: 2, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } } }
      end

      it 'returns an empty array' do
        expect(map.numeric_edge_ids).to eql []
      end
    end

    context 'with one numeric id' do
      let(:edges) do
        { 'HywTymBnW' => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
          '123' => { id: 123, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } } }
      end

      it ' returns array with id' do
        expect(map.numeric_edge_ids).to eql ['123']
      end
    end

    context 'with two numeric ids' do
      let(:edges) do
        { '456' => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
          '123' => { id: 123, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } } }
      end

      it 'returns array of two id' do
        expect(map.numeric_edge_ids.to_set).to eql ['123', '456'].to_set
      end
    end
  end

  describe 'numeric_node_ids' do
    def org
      build(:org).tap do |o|
        allow(o).to receive(:featured_image).and_return(nil)
      end
    end

    let(:nodes) do
      { '123' => Oligrapher.legacy_entity_to_node(org),
        '456' => Oligrapher.legacy_entity_to_node(org),
        'abc' => Oligrapher.legacy_entity_to_node(org) }
    end
    let(:custom_nodes) do
      { '789' => Oligrapher.legacy_entity_to_node(org),
        'abc' => Oligrapher.legacy_entity_to_node(org) }
    end

    let(:graph_data) do
      OligrapherGraphData.new(id: 'abcdefg', nodes: nodes, edges: {}, captions: {})
    end

    let(:custom_graph_data) do
      JSON.dump(id: 'abcdefg', nodes: custom_nodes, edges: {}, captions: {})
    end

    let(:network_map) { build(:network_map, graph_data: graph_data) }

    context 'when using default graph_data' do
      specify do
        expect(network_map.numeric_node_ids).to eql ['123', '456']
      end
    end

    context 'when providing the graph inline' do
      specify do
        expect(network_map.numeric_node_ids(custom_graph_data)).to eql ['789']
      end
    end
  end

  describe 'cloneable?' do
    it 'cloneable if is_cloneable is set' do
      expect(build(:network_map, is_cloneable: true).cloneable?).to be true
    end

    it 'not cloneable if is_cloneable false' do
      expect(build(:network_map, is_cloneable: false).cloneable?).to be false
    end

    it 'not cloneable if private regardless of is_cloneable status' do
      expect(build(:network_map, is_cloneable: true, is_private: true).cloneable?).to be false
    end
  end

  describe 'captions' do
    let(:captions) do
      { '1' => { id: 1, display: { text: "Caption 1" } } }
    end

    let(:graph_data) do
      OligrapherGraphData.new(id: 'abcdefg', nodes: {}, edges: {}, captions: captions)
    end

    let(:network_map) { build(:network_map, graph_data: graph_data) }

    specify do
      expect(network_map.captions).to eq [{ "id" => 1, "display" => { "text" => "Caption 1" } }]
    end
  end

  describe '#display_title' do
    context 'when map is public' do
      let(:map) { build(:network_map, is_private: false) }

      it 'does not display a lock' do
        expect(map.display_title).to eql '"so many connections"'
        expect(map.display_title(lock: true)).to eql '"so many connections"'
      end
    end

    context 'when map is private' do
      let(:map) { build(:network_map, is_private: true) }

      it 'displays lock if param lock is true' do
        expect(map.display_title(lock: true)).to eql '"so many connections 🔒"'
      end

      it 'does not dsiplay lock if lock param is set to false' do
        expect(map.display_title(lock: false)).to eql '"so many connections"'
      end
    end
  end

  describe 'Entity Network Map Collection functions' do
    let(:e1) { create(:entity_org) }
    let(:e2) { create(:entity_org) }

    let(:nodes) do
      { e1.id => Oligrapher.legacy_entity_to_node(e1),
        e2.id => Oligrapher.legacy_entity_to_node(e2) }
    end

    let(:graph_data) do
      OligrapherGraphData.new(id: 'abcdefg', nodes: nodes, edges: {}, captions: {})
    end

    let(:graph_data_missing_node_two) do
      OligrapherGraphData.new(id: 'abcdefg',
                              nodes: { e1.id => Oligrapher.legacy_entity_to_node(e1) },
                              edges: {}, captions: {})
    end

    let(:network_map) { create(:network_map, user_id: 1) }

    before do
      allow(e1).to receive(:featured_image).and_return(nil)
      allow(e2).to receive(:featured_image).and_return(nil)
    end

    describe 'entities_removed_from_graph' do
      specify do
        network_map.graph_data = graph_data
        expect(network_map.entities_removed_from_graph).to eql []
        network_map.save!
        network_map.graph_data = graph_data_missing_node_two
        expect(network_map.entities_removed_from_graph).to eql [e2.id]
      end
    end

    describe 'before_save' do
      context 'with custom title' do
        it 'starts network map job' do
          map = build(:network_map, user_id: 1, graph_data: graph_data)
          expect(UpdateEntityNetworkMapCollectionsJob).to receive(:perform_later).once
          map.save!
        end
      end

      context 'when titled "Untitled Map"' do
        it 'does not start network map job' do
          map = build(:network_map, user_id: 1, title: 'Untitled Map')
          expect(UpdateEntityNetworkMapCollectionsJob).not_to receive(:perform_later)
          map.save!
        end
      end
    end
  end

  describe 'scope_for_user' do
    let(:user1) { create_basic_user }
    let(:user2) { create_basic_user }

    before do
      create(:network_map, user_id: user1.id, is_private: false)
      create(:network_map, user_id: user1.id, is_private: true)
      create(:network_map, user_id: user2.id, is_private: false)
    end

    it 'finds 3 maps for user1' do
      expect(NetworkMap.scope_for_user(user1).count).to eq 3
    end

    it 'finds 2 maps for user2' do
      expect(NetworkMap.scope_for_user(user2).count).to eq 2
    end
  end

  describe 'Collaboration' do
    let(:owner) { create_basic_user }
    let(:other_user) { create_basic_user }
    let(:map) { create(:network_map_version3, user: owner) }

    it 'new map has no editors' do
      expect(NetworkMap.new.editors).to eq []
    end

    describe '#add_editor' do
      it 'adds user to editors array' do
        expect(map.all_editor_ids).to eq []
        expect { map.add_editor(other_user).save! }
          .to change { map.reload.all_editor_ids }.from([]).to([other_user.id])
      end

      it 'adds user by id to editors array' do
        expect(map.all_editor_ids).to eq []
        expect { map.add_editor(other_user.id).save! }
          .to change { map.reload.all_editor_ids }.from([]).to([other_user.id])
      end

      it 'cannot add owner to editors array' do
        expect(map.all_editor_ids).to eq []
        expect { map.add_editor(owner).save }
          .not_to change { map.reload.all_editor_ids }
      end

      it 'validates user id before adding' do
        map.add_editor(5_000_000)
        expect(map.all_editor_ids).to eq []
      end
    end

    specify '#can_edit?' do
      expect(map.can_edit?(owner)).to be true
      expect(map.can_edit?(owner.id)).to be true
      expect(map.can_edit?(other_user)).to be false
      expect(map.can_edit?(other_user.id)).to be false
      map.add_editor(other_user).save!
      map.confirm_editor(other_user).save!
      expect(map.reload.can_edit?(other_user)).to be true
      expect(map.reload.can_edit?(other_user.id)).to be true
    end

    specify '#has_pending_editor?' do
      expect(map.has_pending_editor?(owner)).to be false
      expect(map.has_pending_editor?(other_user)).to be false
      map.add_editor(other_user).save!
      expect(map.has_pending_editor?(other_user)).to be true
      map.confirm_editor(other_user).save!
      expect(map.has_pending_editor?(other_user)).to be false
    end

    describe '#remove_editor' do
      it 'removes user' do
        expect(map.all_editor_ids).to eq []
        map.add_editor(other_user).save!
        expect(map.reload.all_editor_ids).to eq [other_user.id]
        map.remove_editor(other_user).save!
        expect(map.reload.all_editor_ids).to eq []
      end

      it 'silently ignores users not in editor array' do
        map.add_editor(other_user).save!
        expect(map.reload.all_editor_ids).to eq [other_user.id]
        map.remove_editor(5_000_000)
        expect(map.reload.all_editor_ids).to eq [other_user.id]
        expect(map.validate).to be true
      end
    end

    describe '#confirm_editor' do
      it 'confirms pending editor' do
        expect(map.confirmed_editor_ids).to eq []
        map.add_editor(other_user).save!
        expect(map.reload.confirmed_editor_ids).to eq []
        map.reload.confirm_editor(other_user).save!
        expect(map.reload.confirmed_editor_ids).to eq [other_user.id]
      end

      it 'silently ignores user not in editor array' do
        expect(map.confirmed_editor_ids).to eq []
        map.confirm_editor(5_000_000).save!
        expect(map.confirmed_editor_ids).to eq []
        expect(map.validate).to be true
      end
    end
  end # end collaboration

  describe 'soft delete / destroy' do
    let(:network_map) { create(:network_map, user_id: 1) }

    before { network_map }

    it 'destroying removes map from queries' do
      expect { network_map.destroy }.to change(NetworkMap, :count).by(-1)
    end

    it 'destroying soft_deletes map' do
      expect { network_map.destroy }
        .not_to change { NetworkMap.unscoped.count }
    end
  end

  describe '#sources_annotation' do
    let(:network_map) { create(:network_map, user_id: 1) }

    context 'when map is empty' do
      it 'should return nil' do
        expect(network_map.sources_annotation).to be nil
      end
    end

    context 'when map has edges from littlesis' do
      let(:doc) { create(:document) }

      before { allow(network_map).to receive(:documents).and_return([doc]) }

      it 'should return annotation when map has edges with documents' do
        obj = network_map.sources_annotation
        expect(obj[:text]).to include(doc.name)
        expect(obj[:text]).to include(doc.url)
      end
    end
  end
end
