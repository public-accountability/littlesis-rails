# frozen_string_literal: true

require 'rails_helper'

describe OligrapherGraphData do
  describe 'init' do
    it 'creates new hash if nil' do
      expect(OligrapherGraphData.new(nil).hash).to eq({})
    end

    it 'parses json' do
      expect(OligrapherGraphData.new("{\"foo\":\"bar\"}").hash).to eq('foo' => 'bar')
    end

    it 'stores hash' do
      expect(OligrapherGraphData.new("foo" => "bar").hash).to eq('foo' => 'bar')
    end
  end

  describe 'dump' do
    it 'returns nil if given nil' do
      expect(OligrapherGraphData.dump(nil)).to eq nil
    end

    it 'returns nil for empty hashes' do
      expect(OligrapherGraphData.dump(OligrapherGraphData.new({}))).to eq nil
    end

    it 'converts hash to json' do
      expect(OligrapherGraphData.dump(OligrapherGraphData.new({"foo" => "bar"})))
        .to eq "{\"foo\":\"bar\"}"
    end

    it 'raises error if given other object' do
      expect { OligrapherGraphData.dump([]) }
        .to raise_error(OligrapherGraphData::SerializationTypeMismatch)
    end
  end

  describe '==' do
    specify do
      expect(OligrapherGraphData.new('foo' => 'bar') == OligrapherGraphData.new("{\"foo\":\"bar\"}"))
        .to be true
    end

    specify do
      expect(OligrapherGraphData.new('foo => 'bar') == OligrapherGraphData.new("{\"foo\":\"baz\"}"))
        .to be false
    end
  end

  describe 'load' do
    it 'raises error if called with invalid type' do
      expect { OligrapherGraphData.load([]) }.to raise_error(TypeError)
    end

    it 'parses string' do
      expect(OligrapherGraphData.load("{\"foo\":\"bar\"}"))
        .to eq OligrapherGraphData.new('foo' => 'bar')
    end
  end
end
