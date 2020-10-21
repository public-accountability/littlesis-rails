describe Address do
  it { is_expected.to have_db_column(:street1).of_type(:text) }
  it { is_expected.to have_db_column(:street2).of_type(:text) }
  it { is_expected.to have_db_column(:street3).of_type(:text) }
  it { is_expected.to have_db_column(:city).of_type(:text) }
  it { is_expected.to have_db_column(:state).of_type(:string) }
  it { is_expected.to have_db_column(:country).of_type(:string) }
  it { is_expected.to have_db_column(:normalized_address).of_type(:text) }
  it { is_expected.to have_db_column(:location_id).of_type(:integer) }
  it { is_expected.to belong_to(:location) }
end
