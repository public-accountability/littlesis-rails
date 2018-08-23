require 'rails_helper'

# rubocop:disable Style/WordArray

describe Graph do
  describe 'correctly parses edges' do
    let(:edges) { [['a', 'b', 123], ['b', 'c', 456]] }
    subject { Graph.new(edges) }

    it 'sets @graph' do
      expect(subject.graph).to eql('a' => Set['b'],
                                   'b' => Set['a', 'c'],
                                   'c' => Set['b'])
    end

    it 'creates a lookup table' do
      expect(subject.lookup).to eql(['a', 'b'] => 123, ['b', 'c'] => 456)
    end
  end

  describe 'initalized without additional data' do
    let(:edges) { [[1,2], [3,4]] }
    subject { Graph.new(edges) }
    it 'has nil lookup table' do
      expect(subject.lookup).to be nil
    end
  end

  describe 'degree functions' do
    let(:edges) do
      [
        ['a', 'b'],
        ['c', 'a'],
        ['d', 'c'],
        ['e', 'b'],
        ['f', 'g'],
        ['h', 'c']
      ]
    end

    subject { Graph.new(edges) }

    describe 'connected_nodes' do

      describe 'one level deep' do
        specify do
          expect(subject.connected_nodes('a', max_depth: 1))
            .to eql [Set['b', 'c']]
        end

        specify do
          expect(subject.connected_nodes('f', max_depth: 1))
            .to eql [Set['g']]
        end
      end

      describe 'two levels deep' do
        specify do
          expect(subject.connected_nodes('a', max_depth: 2))
            .to eql [Set['b', 'c'], Set['d', 'e', 'h']]
        end

        specify do
          expect(subject.connected_nodes('f', max_depth: 2))
            .to eql [Set['g'], Set[]]
        end
      end

      describe 'can be initalized with two values' do
        specify do 
          expect(subject.connected_nodes(['e', 'f']))
            .to eql [Set['g', 'b']]
        end
      end

      describe 'max MAX dpeth ' do
        specify do
          expect(subject.connected_nodes('f', max_depth: 1_000_000))
            .to eql [Set['g'], Set[]]
        end
      end
    end
  end
end

# rubocop:enable Style/WordArray
