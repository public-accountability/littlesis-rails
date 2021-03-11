describe FECMatch do
  it { is_expected.to have_db_column(:fec_sub_id) }
  it { is_expected.to have_db_column(:relationship_id) }
  it { is_expected.to have_db_column(:donor_id) }
  it { is_expected.to have_db_column(:recipient_id) }
end
