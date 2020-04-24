describe ExternalEntity, type: :model do
  it { is_expected.to have_db_column(:dataset).of_type(:integer) }
  it { is_expected.to have_db_column(:match_data).of_type(:text) }
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:external_data_id).of_type(:integer) }
  it { is_expected.to belong_to(:external_data) }
  it { is_expected.to belong_to(:entity).optional }
end
