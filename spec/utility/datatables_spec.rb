describe Datatables do
  describe Datatables::Params do
    let(:controller_params) do
      ActionController::Parameters.new(
        {
          dataset: 'nycc',
          draw: '123',
          search: { value: '', regex: 'false' },
          start: 0,
          length: 10,
          columns: {
            '0' => { data: 'id', name: '' },
            '1' => { data: 'match', name: '' },
            '2' => { data: 'data.FullName', name: '' }
          },
          order: {
            '0' => { 'column' => '2', 'dir' => 'desc' },
            '1' => { 'column' => '0', 'dir' => 'asc' }
          }
        }
      )
    end

    let(:params) do
      Datatables::Params.new controller_params
    end

    it 'sets params, draw, start, length' do
      expect(params.params). to be controller_params
      expect(params.draw).to eq 123
      expect(params.start).to eq 0
      expect(params.length).to eq 10
    end

    it 'sets @search' do
      expect(params.search).to eq({ value: '', regex: false }.with_indifferent_access)
    end

    it 'sets @columns' do
      expect(params.columns).to be_a Array
      expect(params.columns.length).to eq 3
      expect(params.columns[0]['data']).to eq 'id'
    end

    it 'sets @order' do
      expect(params.order).to eq([
                                   { 'column' => '2', 'dir' => 'desc' }.with_indifferent_access,
                                   { 'column' => '0', 'dir' => 'asc' }.with_indifferent_access
                                 ])
    end
  end
end
