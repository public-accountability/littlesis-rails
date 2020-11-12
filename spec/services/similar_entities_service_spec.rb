describe SimilarEntitiesService do
  let(:entity) do
    build(:person).tap do |entity|
      entity.build_person(name_first: 'Human', name_last: 'Being')
    end
  end

  let(:search_terms) { "(*Human Being*) | (Human Being) | (Human * Being)" }
  let(:search_query) { "@!summary #{search_terms}" }

  it 'sets per_page by default' do
    expect(SimilarEntitiesService.new(entity).per_page).to eq 5
  end

  it 'call Entity.search with correct search terms' do
    expect(Entity).to receive(:search).with(search_query, kind_of(Hash)).once
    SimilarEntitiesService.new(entity).similar_entities
  end

  it 'query can be customized' do
    expect(Entity).to receive(:search).with("@!summary foo", kind_of(Hash)).once
    SimilarEntitiesService.new(entity, query: 'foo').similar_entities
  end

  describe 'search options' do
    subject { SimilarEntitiesService.new(entity).send(:search_options) }

    specify { expect(subject[:without]).to eq(sphinx_internal_id: entity.id)}
    assert_attribute :with, { primary_ext: 'Person', is_deleted: false }
    assert_attribute :per_page, 5
    assert_attribute :field_weights, { name: 15, aliases: 10, blurb: 3 }
  end
end
