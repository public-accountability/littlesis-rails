require 'rails_helper'

# rubocop:disable Style/WordArray

describe Graph do
  describe 'correctly parses edges' do
    let(:edges) do
      { ['a', 'b'] => 123,
        ['b', 'c'] => 456 }
    end

    subject { Graph.new(edges) }

    it 'sets @graph' do
      expect(subject.instance_variable_get(:@graph))
        .to eql('a' => Set['b'],
                'b' => Set['a', 'c'],
                'c' => Set['b'])
    end
  end

  describe 'degree functions' do
    let(:edges) do
      {
        ['a', 'b'] => 1,
        ['c', 'a'] => 2,
        ['d', 'c'] => 3,
        ['e', 'b'] => 4,
        ['f', 'g'] => 5,
        ['h', 'c'] => 6
      }
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
