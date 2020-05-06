describe ExternalEntityPresenter do
  context 'with an iapd advisor' do
    let(:external_data) { build(:external_data_iapd_advisor2) }
    let(:external_entity) do
      build(:external_entity,
            dataset: 'iapd_advisors',
            external_data: external_data)
    end

    specify 'display_information' do
      presenter = ExternalEntityPresenter.new(external_entity)
      expect(presenter.display_information)
        .to eq('Name' => "Timothy J. Ellis, Inc.",
               'SEC File Number' => "801-80511",
               'CRD Number' => "126188",
               'Assets under management' => 72450685,
               'Latest filing date' => "02/26/2019 04:05:44 PM")
    end

  end
end
