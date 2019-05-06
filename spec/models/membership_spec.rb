describe Membership do
  it { is_expected.to belong_to(:relationship) }
  it { is_expected.to have_db_column(:dues) }
  it { is_expected.to have_db_column(:elected_term) }
end
