require 'rails_helper'

describe RelationshipsGraph do
  describe 'correctly parses relationship data' do
    let(:relationships) do
      [{ 'id'=> 123,
         'entity1_id' => 'a',
         'entity2_id' => 'b',
         'category_id' => 1 },
       { 'id' => 456,
         'entity1_id' => 'b',
         'entity2_id' => 'c',
         'category_id' => 2 }]
    end

    subject { RelationshipsGraph.new(relationships) }

    it 'creates edges' do
      expect(subject.edges)
        .to eql(123  => { 'entity1_id' => 'a', 'entity2_id' => 'b', 'category_id' => 1 },
                456  => { 'entity1_id' => 'b', 'entity2_id' => 'c', 'category_id' => 2 })
    end

    it 'sets nodes' do
      expect(subject.nodes)
        .to eql('a' => { ids: Set[123], associated: Set['b'] },
                'b' => { ids: Set[123, 456], associated: Set['a','c'] },
                'c' => { ids: Set[456], associated: Set['b'] })
    end
  end

  describe 'connected_nodes' do
    let(:relationships) do
      [
        { 'id' => 1, 'entity1_id' => 'a', 'entity2_id' => 'b', 'category_id' => 12 },
        { 'id' => 2, 'entity1_id' => 'c', 'entity2_id' => 'a', 'category_id' => 11 },
        { 'id' => 3, 'entity1_id' => 'd', 'entity2_id' => 'c', 'category_id' => 10 },
        { 'id' => 4, 'entity1_id' => 'e', 'entity2_id' => 'f', 'category_id' => 9 },
        { 'id' => 5, 'entity1_id' => 'e', 'entity2_id' => 'b', 'category_id' => 8 },
        { 'id' => 6, 'entity1_id' => 'f', 'entity2_id' => 'g', 'category_id' => 7 },
        { 'id' => 7, 'entity1_id' => 'h', 'entity2_id' => 'c', 'category_id' => 6 },
        { 'id' => 8, 'entity1_id' => 'a', 'entity2_id' => 'd', 'category_id' => 6 }
      ]
    end

    subject { RelationshipsGraph.new(relationships) }

    describe 'one level deep' do
      specify do
        expect(subject.connected_nodes('a', max_depth: 1))
          .to eql [Set['b', 'c', 'd']]
      end

      specify do
        expect(subject.connected_nodes('f', max_depth: 1))
          .to eql [Set['g', 'e']]
      end
    end

    describe 'two levels deep' do
      specify do
        expect(subject.connected_nodes('a', max_depth: 2))
          .to eql [Set['b', 'c', 'd'], Set['e', 'h']]
      end

      specify do
        expect(subject.connected_nodes('f', max_depth: 2))
          .to eql [Set['e', 'g'], Set['b']]
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
          .to eql [Set['g', 'e'], Set['b'], Set['a'], Set['c', 'd'], Set['h'], Set.new]
      end
    end

    describe 'connected ids' do
      it 'returns ids for "a", one level deep' do
        expect(subject.connected_ids('a', max_depth: 1))
            .to eql [Set[1, 2, 8]]
      end

      it 'returns ids for "a", four levels deep' do
        expect(subject.connected_ids('a', max_depth: 4))
            .to eql [Set[1, 2, 8], Set[3, 7 , 5], Set[4], Set[6]]
      end

      it 'returns ids for ["a", "b"], two levels deep' do
        expect(subject.connected_ids(['a', 'b'], max_depth: 2))
            .to eql [Set[1, 2, 8,5], Set[3, 7, 4]]
      end
    end

  end
end

# rubocop:enable Style/WordArray
