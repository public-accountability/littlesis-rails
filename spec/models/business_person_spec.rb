describe BusinessPerson, :external_link, :type => :model do
  it { is_expected.to have_db_column(:sec_cik) }
  it { is_expected.not_to have_db_column(:crd_number) }
  create_or_update_external_link_test('business_person', 'person')
end
