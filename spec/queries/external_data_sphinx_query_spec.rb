describe ExternalDataSphinxQuery, :sphinx do
  before(:all) do
    setup_sphinx do
      create :external_data_nys_disclosure
      create :external_data_nys_disclosure_transaction_code_f
      create :external_data_nys_filer
      create :external_data_schedule_a
    end
  end

  after(:all) do
    teardown_sphinx { ExternalData.delete_all }
  end

  let(:search_value) { '' }

  let(:params) do
    Datatables::Params.new(
      ActionController::Parameters.new(
        dataset: 'nys_disclosure',
        draw: 1,
        start: 0,
        length: 10,
        search: { value: search_value },
        columns: {
          '0' => { data: 'id' },
          '1' => { data: 'amount' },
          '2' => { data: 'date' }
        },
        order: {
          '0' => { 'column' => 1, 'dir' => 'desc' }
        }
      )
    )
  end

  describe 'empty search' do
    it 'orders by amount' do
      response = ExternalDataSphinxQuery.run(params)
      expect(response).to be_a Datatables::Response
      expect(response.recordsFiltered).to eq 2
      expect(response.data.first['nice']['amount']).to eq 1_800
    end
  end

  describe 'searching for a name' do
    let(:search_value) { 'frank' }

    it 'filters results' do
      response = ExternalDataSphinxQuery.run(params)
      expect(response.recordsFiltered).to eq 1
      expect(response.data.first['data']['FIRST_NAME_40']).to eq 'FRANK'
    end
  end
end
