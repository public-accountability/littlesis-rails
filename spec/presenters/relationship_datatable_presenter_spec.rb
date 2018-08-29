require 'rails_helper'

describe RelationshipDatatablePresenter do
  let(:entity) { create(:entity_person) }
  let(:related) { create(:entity_org) }
  let(:relationship) do
    create(:position_relationship, entity: entity, related: related, is_current: true)
  end

  subject { RelationshipDatatablePresenter.new(relationship).to_h }

  it do
    is_expected.to eql('id' => relationship.id,
                       'entity1_id' => entity.id,
                       'entity2_id' => related.id,
                       'start_date' => nil,
                       'end_date' => nil,
                       'category_id' => 1,
                       'url' => "http://localhost:8080/relationships/#{relationship.id}",
                       'is_board' => nil,
                       'is_executive' => nil,
                       'amount' => nil,
                       'is_current' => true,
                       'label_for_entity1' => 'Position',
                       'label_for_entity2' => 'Position')
  end
end
