require 'rails_helper'

# rubocop:disable Style/StringLiterals, Style/WordArray

describe NetworkMap, type: :model do
  it { is_expected.to belong_to(:sf_guard_user) }
  it { is_expected.to belong_to(:user) }
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe '#annotations_data_with_sources' do
    let(:annoations_data) { "[{\"id\":\"B14l9k6ug\",\"header\":\"Untitled Annotation\",\"text\":\"\",\"nodeIds\":[],\"edgeIds\":[\"411302\"],\"captionIds\":[]}]" }
  end

  describe '#generate_index_data' do
    let(:e1) { create(:person, :with_person_name, blurb: 'xyz') }
    let(:e2) { create(:person, :with_person_name, blurb: nil) }
    let(:graph_data) do
      JSON.dump(id: 'abcdefg',
                nodes: {
                  e1.id => Oligrapher.entity_to_node(e1),
                  e2.id => Oligrapher.entity_to_node(e2)
                },
                edges: {},
                captions: { '1' => { id: 1, display: { text: "Caption 1" } } })
    end

    let(:network_map) { build(:network_map, graph_data: graph_data) }

    it 'generates string of index data' do
      expect(network_map.generate_index_data)
        .to eql "#{e1.name}, xyz, #{e2.name}, Caption 1"
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
      JSON.dump(id: 'xyz', nodes: {}, captions: {}, edges: edges)
    end
    let(:urls) { Array.new(2) { Faker::Internet.unique.url } }
    let(:map) { build(:network_map, graph_data: graph_data) }

    it 'returns uniq set of documents' do
      # The relationships should have 3 references, with 2 uniq urls
      relationships.first.add_reference(url: urls[0], name: Faker::Lorem.sentence)
      relationships.second.add_reference(url: urls[0], name: Faker::Lorem.sentence)
      relationships.second.add_reference(url: urls[1], name: Faker::Lorem.sentence)

      expect(map.documents.to_set).to eql([Document.find_by_url(urls.first), Document.find_by_url(urls.second)].to_set)
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
      JSON.dump(id: 'xyz', nodes: {}, captions: {}, edges: edges)
    end
    let(:map) { build(:network_map, graph_data: graph_data) }

    it 'retrives relationship from graph data' do
      expect(Relationship).to receive(:where).with(id: ['123', '456'])
      map.rels
    end
  end

  describe 'edge_ids' do
    let(:graph_data) do
      JSON.dump(id: 'NkpdQPQfx',
                nodes: {},
                edges: {
                  '1' => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
                  '2' => { id: 2, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } }
                },
                captions: { '1' => { id: 1, display: { text: "Caption 1" } } })
    end

    let(:map) { build(:network_map, graph_data: graph_data) }

    it 'returns list of ids' do
      expect(Set.new(map.edge_ids)).to eql ['1', '2'].to_set
    end
  end

  describe 'numeric edge ids' do
    let(:edges) { {} }
    let(:graph_data) do
      JSON.dump(id: 'xyz', nodes: {}, captions: {}, edges: edges)
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

  # describe '' do
    

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

  xdescribe 'Entity Network Map Collection functions' do
    let(:e1) { build(:org) }
    let(:e2) { build(:org) }

    let(:nodes) do
      { e1.id => Oligrapher.entity_to_node(e1),
        e2.id => Oligrapher.entity_to_node(e2) }
    end

    let(:graph_data) do
      JSON.dump(id: 'abcdefg', nodes: nodes, edges: {}, captions: {})
    end

    let(:network_map) { build(:network_map, id: rand(1000), graph_data: graph_data) }

    describe 'update_entity_network_map_collections' do

      it 'adds id for all entities' do
        expect(network_map).to recieve(:entities).once.and_return([e1, e2])
      end

      it 'when an entity is removed, it removes it from the associated entity'
    end
  end

end

# rubocop:enable Style/StringLiterals, Style/WordArray
