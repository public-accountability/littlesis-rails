describe ExternalRelationship, type: :model do
  it { is_expected.to belong_to(:external_data) }
  it { is_expected.to belong_to(:relationship) }
  it { is_expected.to have_db_column(:dataset).of_type(:integer) }
  it { is_expected.to have_db_column(:entity1_id).of_type(:integer) }
  it { is_expected.to have_db_column(:entity2_id).of_type(:integer) }
  it { is_expected.to have_db_column(:category_id).of_type(:integer) }
  it { is_expected.to have_db_column(:relationship_attributes).of_type(:text) }
end
