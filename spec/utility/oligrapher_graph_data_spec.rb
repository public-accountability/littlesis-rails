# frozen_string_literal: true

describe OligrapherGraphData do
  let(:nodes_hash) do
    { 'nodes' => { '123' => { 'id' => '123', 'color' => '#ccc' } } }
  end

  let(:nodes_json) { JSON.generate(nodes_hash) }

  describe 'init' do
    it 'creates new hash if nil' do
      expect(OligrapherGraphData.new(nil).hash).to eq({ nodes: {}, edges: {}, captions: {} }.with_indifferent_access)
    end

    it 'parses json' do
      expect(OligrapherGraphData.new(nodes_json).hash).to eq nodes_hash.merge(edges: {}, captions: {}).with_indifferent_access
    end

    it 'stores hash' do
      expect(OligrapherGraphData.new(nodes_hash).hash).to eq nodes_hash.merge(edges: {}, captions: {}).with_indifferent_access
    end
  end

  describe 'dump' do
    it 'converts hash to json via to_json' do
      expect(OligrapherGraphData.new(nodes_hash).to_json)
        .to eq JSON.generate(nodes_hash.merge(edges: {}, captions: {}))
    end
  end

  describe '==' do
    specify do
      expect(OligrapherGraphData.new(nodes_hash) == OligrapherGraphData.new(nodes_json))
        .to be true
    end

    specify do
      expect(OligrapherGraphData.new == OligrapherGraphData.new(nodes_hash)).to be false
    end
  end

  describe 'load' do
    it 'raises error if called with invalid type' do
      expect { OligrapherGraphData.load([]) }.to raise_error(TypeError)
    end

    it 'parses string' do
      expect(OligrapherGraphData.load(nodes_json)).to eq OligrapherGraphData.new(nodes_hash)
    end

    it 'duplicate OligrapherGraphData' do
      expect(OligrapherGraphData.load(OligrapherGraphData.new(nodes_hash)))
        .to eq OligrapherGraphData.new(nodes_hash)
    end
  end
end
