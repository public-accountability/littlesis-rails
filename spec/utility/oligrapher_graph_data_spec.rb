# frozen_string_literal: true


describe OligrapherGraphData do
  let(:foo_bar_hash) { { 'foo' => 'bar' } }
  let(:foo_bar_json) { "{\"foo\":\"bar\"}" }

  describe 'init' do
    it 'creates new hash if nil' do
      expect(OligrapherGraphData.new(nil).hash).to eq({})
    end

    it 'parses json' do
      expect(OligrapherGraphData.new(foo_bar_json).hash).to eq foo_bar_hash
    end

    it 'stores hash' do
      expect(OligrapherGraphData.new(foo_bar_hash).hash).to eq foo_bar_hash
    end
  end

  describe 'dump' do
    it 'converts hash to json via to_json' do
      expect(OligrapherGraphData.new(foo_bar_hash).to_json)
        .to eq foo_bar_json
    end
  end

  describe '==' do
    specify do
      expect(OligrapherGraphData.new(foo_bar_hash) == OligrapherGraphData.new(foo_bar_json))
        .to be true
    end

    specify do
      expect(OligrapherGraphData.new(foo_bar_hash) == OligrapherGraphData.new("{\"foo\":\"baz\"}"))
        .to be false
    end
  end

  describe 'load' do
    it 'raises error if called with invalid type' do
      expect { OligrapherGraphData.load([]) }.to raise_error(TypeError)
    end

    it 'parses string' do
      expect(OligrapherGraphData.load(foo_bar_json)).to eq OligrapherGraphData.new(foo_bar_hash)
    end

    it 'duplicate OligrapherGraphData' do
      expect(OligrapherGraphData.load(OligrapherGraphData.new(foo_bar_hash)))
        .to eq OligrapherGraphData.new(foo_bar_hash)
    end
  end
end
