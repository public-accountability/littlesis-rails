describe ExternalRelationship, type: :model do
  it { is_expected.to belong_to(:external_data) }
  it { is_expected.to belong_to(:relationship).optional }
  it { is_expected.to have_db_column(:dataset).of_type(:integer) }
  it { is_expected.to have_db_column(:entity1_id).of_type(:integer) }
  it { is_expected.to have_db_column(:entity2_id).of_type(:integer) }
  it { is_expected.to have_db_column(:category_id).of_type(:integer) }
  it { is_expected.to have_db_column(:relationship_attributes).of_type(:text) }

  specify 'matched?' do
    expect(ExternalRelationship.new.matched?).to be false
    expect(ExternalRelationship.new(entity1_id: 1, entity2_id: nil).matched?).to be false
    expect(ExternalRelationship.new(entity1_id: nil, entity2_id: 2).matched?).to be false
    expect(ExternalRelationship.new(entity1_id: 1, entity2_id: 2).matched?).to be true
  end
end
