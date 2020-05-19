describe ExternalEntityPresenter do
  context 'with an iapd advisor' do
    let(:external_data) { build(:external_data_iapd_advisor) }
    let(:external_entity) do
      build(:external_entity, dataset: 'iapd_advisors', external_data: external_data)
    end

    specify 'display_information' do
      presenter = ExternalEntityPresenter.new(external_entity)
      expect(presenter.display_information)
        .to eq('Name' => "Boenning & Scattergood, Inc.",
               'CRD Number' => "100",
               'SEC File Number' => "801-80511",
               'Assets under management' => "2.4 Billion",
               'Latest filing date' => "11/13/2019 05:12:22 PM")
    end
  end
end
