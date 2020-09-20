describe RelationshipDatatablePresenter do
  let(:entity) { create(:entity_person) }
  let(:related) { create(:entity_org) }
  let(:relationship) do
    create(:position_relationship, entity: entity, related: related, is_current: true)
  end

  subject { RelationshipDatatablePresenter.new(relationship).to_h }

  let(:result) do
    { 'id' => relationship.id,
      'entity1_id' => entity.id,
      'entity2_id' => related.id,
      'start_date' => nil,
      'end_date' => nil,
      'category_id' => 1,
      'url' => "http://test.host/relationships/#{relationship.id}",
      'is_board' => nil,
      'is_executive' => nil,
      'amount' => nil,
      'is_current' => true,
      'label_for_entity1' => 'Position',
      'label_for_entity2' => 'Position' }
  end

  it { is_expected.to eql(result) }

  context 'with an additional fields' do
    subject { RelationshipDatatablePresenter.new(relationship, { 'interlocked' => [123] }).to_h }
    it { is_expected.to eql(result.merge('interlocked' => [123])) }
  end
end
