describe PublicCompany, :external_link, :type => :model do
  it { is_expected.to belong_to(:entity) }
  it { is_expected.to validate_length_of(:ticker).is_at_most(10) }
  it { is_expected.to have_db_column(:sec_cik) }
end
