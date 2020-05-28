describe DatatablesService do
  describe 'initialize' do
    let(:params) do
      {
        'dataset' => "nycc",
        'draw' => '31',
        'start' => 0,
        'length' => 50,
        "search" => { "value" => "example", "regex" => "false" },
        "columns" => {}
      }
    end

    it 'initializes attributes' do
      ds = DatatablesService.new(params)
      expect(ds.draw).to eq 31
      expect(ds.start).to eq 0
      expect(ds.length).to eq 50q
      expect(ds.search[:value]).to eq 'example'
      expect(ds.search[:regex]).to be false
    end
  end

  describe 'parsing columns' do
    let(:params) do
      {
        "draw" => "1",
        "columns" =>  {
          "0" => { "data" => "0", "name" => "", "searchable" => "true", "orderable" => "true", "search" => { "value" => "", "regex" => "false" } },
          "1" => { "data" => "1", "name" => "", "searchable" => "true", "orderable" => "true", "search" => { "value" => "", "regex" => "false" } },
          "2" => { "data" => "2", "name" => "", "searchable" => "true", "orderable" => "true", "search" => { "value" => "", "regex" => "false" } }
        },
        "order" => {
          "0" => { "column" => "0", "dir" => "asc" }
        },
        "start" => "0",
        "length" => "10",
        "search" => { "value" => "", "regex" => "false" },
        "_" => "1590502280466",
        "dataset" => "nycc"
      }
    end

    it 'parses datatables column request input' do
      columns = DatatablesService.new(params).columns
      expect(columns).to be_a Array
      expect(columns.length).to eq 3
      expect(columns.first).to be_a Hash
    end
  end
end
