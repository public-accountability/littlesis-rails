describe RelationshipsDatatable do
  let(:entity) { create(:entity_person) }
  let(:related) { Array.new(2) { create(:entity_org) } }
  let(:interlocked) { create(:entity_person) }

  let!(:relationships) do
    [Relationship.create!(category_id: 1, entity: entity, related: related[0]),
     Relationship.create!(category_id: 12, entity: entity, related: related[1]),
     Relationship.create!(category_id: 12, entity: related[0], related: interlocked)]
  end

  subject(:datatable) { RelationshipsDatatable.new(entity) }

  describe 'root_entities' do
    subject { datatable.root_entities }
    it { is_expected.to eql [entity] }
  end

  describe 'root_entity_ids' do
    subject { datatable.root_entity_ids }
    it { is_expected.to eql [entity.id] }
  end

  describe 'links' do
    subject { datatable.links.to_a.to_set }
    it { is_expected.to eql entity.links.to_a.to_set }
  end

  describe 'related_ids' do
    specify do
      expect(datatable.related_ids.to_set).to eql entity.links.pluck(:entity2_id).to_set
    end
  end

  describe 'entities' do
    subject { datatable.entities }
    it do
      is_expected.to eql(entity.id => EntityDatatablePresenter.new(entity).to_hash,
                         related[0].id => EntityDatatablePresenter.new(related[0]).to_hash,
                         related[1].id => EntityDatatablePresenter.new(related[1]).to_hash)
    end
  end

  describe 'relationships' do
    subject { datatable.relationships.to_set }
    it do
      is_expected.to eql([RelationshipDatatablePresenter.new(relationships[0], 'interlocks' => [interlocked.id]).to_h,
                          RelationshipDatatablePresenter.new(relationships[1], 'interlocks' => []).to_h].to_set)
    end
  end

  describe 'rgraph' do
    specify { expect(datatable.rgraph).to be_a RelationshipsGraph }
  end

  describe 'interlocks' do
    subject { datatable.interlocks }
    it do
      is_expected.to eql([{ 'id' => interlocked.id, 'name' => interlocked.name, 'interlocks_count' => 1 }])
    end

    specify do
      expect(datatable.instance_variable_get(:@interlocks_entity_ids))
        .to eql [interlocked.id].to_set
    end
  end
end
