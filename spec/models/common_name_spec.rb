describe CommonName, type: :model do
  it { is_expected.to have_db_column(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  it 'upcases name before saving' do
    expect(CommonName.create!(name: 'jones').name).to eql 'JONES'
  end

  it 'rejects blank strings' do
    expect { CommonName.create(name: '') }.not_to change { CommonName.count }
  end

  describe 'CommonName.includes?' do
    before { CommonName.create!(name: 'JONES') }
    specify { expect(CommonName.includes?('JONES')).to be true }
    specify { expect(CommonName.includes?('jones')).to be true }
    specify { expect(CommonName.includes?('unusualname')).to be false }
  end
end
