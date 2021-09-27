describe ExternalDataset, type: :model do
  it 'has shortcut to fetch individual dataset class' do
    expect(ExternalDataset.nycc).to eql ExternalDataset::NYCC
  end
end
