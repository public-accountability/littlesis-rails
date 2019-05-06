describe OsCommittee, type: :model do
  it { should have_db_column(:cycle) }
  it { should have_db_column(:cmte_id) }
  it { should have_db_column(:name) }
  it { should have_db_column(:affiliate) }
  it { should have_db_column(:ultorg) }
  it { should have_db_column(:recipid) }
  it { should have_db_column(:recipcode) }
  it { should have_db_column(:feccandid) }
  it { should have_db_column(:party) }
  it { should have_db_column(:primcode) }
  it { should have_db_column(:source) }
  it { should have_db_column(:sensitive) }
  it { should have_db_column(:foreign) }
  it { should have_db_column(:active_in_cycle) }
end
