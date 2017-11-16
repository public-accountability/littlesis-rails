require 'rails_helper'

describe NetworkMap, type: :model do
  it { should belong_to(:sf_guard_user) }
  it { should belong_to(:user) }

  describe '#annotations_data_with_sources' do
    let(:annoations_data) { "[{\"id\":\"B14l9k6ug\",\"header\":\"Untitled Annotation\",\"text\":\"\",\"nodeIds\":[],\"edgeIds\":[\"411302\"],\"captionIds\":[]}]" }
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
      html = [ '<div><a href="' + documents[0].url + '">' + documents[0].name + '</a></div>',
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
      JSON.dump({ id: 'xyz', nodes: {}, captions: {}, edges: edges })
    end
    let(:map) { build(:network_map, graph_data: graph_data) }

    it 'retrives relationship from graph data' do
      expect(Relationship).to receive(:where).with(id: ['123', '456'])
      map.rels
    end
  end

  describe 'edge_ids' do
    let(:graph_data) do
      JSON.dump({
                  id: 'NkpdQPQfx',
                  nodes: {},
                  edges: {
                    '1' => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
                    '2' => { id: 2, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } }
                  },
                  captions: { '1' => { id: 1, display: { text: "Caption 1" } } }
                })
    end
    let(:map) { build(:network_map, graph_data: graph_data) }

    it 'returns list of ids' do
      expect(Set.new(map.edge_ids)).to eql ['1', '2'].to_set
    end
  end

  describe 'numeric ids' do
    let(:edges) { {} }
    let(:graph_data) do
      JSON.dump({ id: 'xyz', nodes: {}, captions: {}, edges: edges })
    end
    let(:map) { build(:network_map, graph_data: graph_data) }

    context 'with no numberic ids' do
      let(:edges) do
        { 'HywTymBnW' => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
          'BkVslmr2-' => { id: 2, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } } }
      end
      
      it ' returns an empty array' do
        expect(map.numeric_ids).to eql []
      end
    end

    context 'with one numeric id' do
      let(:edges) do
        { 'HywTymBnW' => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
          '123' => { id: 123, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } } }
      end
      
      it ' returns array with id' do
        expect(map.numeric_ids).to eql ['123']
      end
    end

    context 'with two numeric ids' do
      let(:edges) do
        { '456' => { id: 1, node1_id: 1, node2_id: 2, display: { label: "Edge 1" } },
          '123' => { id: 123, node1_id: 2, node2_id: 3, display: { label: "Edge 2" } } }
      end

      it 'returns array of two id' do
        expect(map.numeric_ids.to_set).to eql ['123', '456'].to_set
      end
    end
  end

end
