require 'rails_helper'

# rubocop:disable Style/WordArray

describe Graph do

  describe 'correctly parses matrix' do
    let(:edges) do
      { ['a', 'b'] => 123,
        ['b', 'c'] => 456 }
    end

    subject { Graph.new(edges) }

    it 'sets @nodes' do
      expect(subject.instance_variable_get(:@nodes))
        .to eql ['a', 'b', 'c']
    end

    it 'sets @index_to_node' do
      expect(subject.instance_variable_get(:@index_to_node))
        .to eql({
                  0 => 'a',
                  1 => 'b',
                  2 => 'c'
                })
    end

    it 'sets @node_to_index' do
      expect(subject.instance_variable_get(:@node_to_index))
        .to eql({
                  'a' => 0,
                  'b' => 1,
                  'c' => 2
                })
    end

    it 'builds the matrix' do
      expect(subject.matrix)
        .to eql Matrix.rows([[nil, 123, nil], [nil, nil, 456], [nil, nil, nil]])
    end
  end

  describe 'degree functions' do
    let(:edges) do
      {
        ['a', 'b'] => 1,
        ['c', 'a'] => 2,
        ['d', 'c'] => 3
      }
    end
    subject { Graph.new(edges) }

    describe 'first_degree_relationships' do
      it 'raises error if node is not in the graph' do
        expect { subject.first_degree_relationships('x') }
          .to raise_error(Graph::NodeNotInGraphError)
      end

      specify do
        expect(subject.first_degree_relationships('a')).to eql Set[1,2]
      end

      specify do
        expect(subject.first_degree_relationships('b')).to eql Set[1]
      end
    end
    

  end
end

# rubocop:enable Style/WordArray
