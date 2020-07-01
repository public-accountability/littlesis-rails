describe NYSFilerImporter do
  let(:test_filer_data) do
    Rails.root.join('spec/testdata/nys_campaign_finance_commcand.zip')
  end

  before do
    stub_const('NYSFilerImporter::FILER_LOCAL_PATH', test_filer_data)
  end

  it 'creates 10 ExternalData' do
    expect { NYSFilerImporter.run }.to change(ExternalData, :count).by(10)
  end
end
