describe ExternalDatasetHelper, type: :helper do
  it 'generates title for advisors' do
    expect(helper.external_dataset_iapd_subtitle('advisors'))
      .to include "<span>IAPD advisors</span>"
  end

  it 'generates title for owners/executives' do
    expect(helper.external_dataset_iapd_subtitle('owners'))
      .to include "<span>IAPD executives</span>"
  end
end
