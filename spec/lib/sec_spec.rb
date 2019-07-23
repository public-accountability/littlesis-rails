describe Sec do
  describe Sec::Filings do
    let(:xml) do
      File.read Rails.root.join('spec', 'testdata', 'gs.xml')
    end
    
    describe 'get_xml' do
      let(:params) do
        { 'action' => 'getcompany',
          'output' => 'xml',
          'start' => 0,
          'count' => 100,
          'CIK' => Sec::CIKS.fetch('GS') }
      end

      it 'calls makes GET request to sec.gov' do
        expect(HTTParty).to receive(:get)
                              .with('http://www.sec.gov/cgi-bin/browse-edgar', query: params)
                              .once
                              .and_return(double(body: xml))

        Sec::Filings.get_xml(Sec::CIKS['GS'])
      end
    end

    describe 'parse_filings_xml' do
      specify do
        expect(Sec::Filings.parse_filings_xml(xml).length).to eq 100
      end

      specify do
        expect(Sec::Filings.parse_filings_xml(xml).first)
          .to eq Sec::Filings::Filing.new(date: '2019-07-23',
                                          href: 'https://www.sec.gov/Archives/edgar/data/886982/000156459019025565/0001564590-19-025565-index.htm',
                                          form_name: 'Prospectus [Rule 424(b)(2)]',
                                          type: '424B2')
      end
    end
  end
end
