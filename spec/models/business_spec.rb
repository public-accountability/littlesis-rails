describe Business do
  it { is_expected.to have_db_column(:assets) }
  it { is_expected.to have_db_column(:marketcap) }
  it { is_expected.to have_db_column(:net_income) }
  it { is_expected.not_to have_db_column(:crd_number) }
  it { is_expected.to have_db_column(:aum).of_type(:integer) }

  it 'has assets_under_management alias' do
    b = build(:business, aum: 5_000)
    expect(b.aum).to eq 5_000
    expect(b.assets_under_management).to eq 5_000
  end
end
