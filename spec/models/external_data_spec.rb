describe ExternalData, type: :model do
  it { is_expected.to have_db_column(:dataset).of_type(:integer) }
  it { is_expected.to have_db_column(:dataset_id).of_type(:string) }
  it { is_expected.to have_db_column(:data).of_type(:text) }
end
