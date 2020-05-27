describe DatatablesParams do
  let(:params) do
    DatatablesParams.new(
      ActionController::Parameters.new(
        {
          "draw" => "31",
          "columns" =>  {
            "0" => { "data" => "0", "name" => "", "searchable" => "true", "orderable" => "true", "search" => { "value" => "", "regex" => "false" } },
            "1" => { "data" => "1", "name" => "", "searchable" => "true", "orderable" => "true", "search" => { "value" => "", "regex" => "false" } },
            "2" => { "data" => "2", "name" => "", "searchable" => "true", "orderable" => "true", "search" => { "value" => "", "regex" => "false" } }
          },
          "order" => {
            "0" => { "column" => "0", "dir" => "asc" }
          },
          "start" => "0",
          "length" => "50",
          "search" => { "value" => "", "regex" => "false" },
          "_" => "1590502280466",
          "dataset" => "nycc"
        }
      )
    )
  end

  it 'sets draw, start, and length' do
    expect(params.draw).to eq 31
    expect(params.start).to eq 0
    expect(params.length).to eq 50
  end

  it 'parses datatables column request input' do
    expect(params.columns).to be_a Array
    expect(params.columns.length).to eq 3
    expect(params.columns.first).to be_a Hash
  end
end
