describe Sec do
  describe Sec::Filings do
    describe 'get_xml' do
      let(:params) do
        { 'action' => 'getcompany',
          'output' => 'xml',
          'start' => 0,
          'count' => 100,
          'CIK' => Sec::CIKS.fetch('GS') }
      end

      let(:xml) do
        File.read Rails.root.join('spec', 'testdata', 'gs.xml')
      end

      it 'calls makes GET request to sec.gov' do
        expect(HTTParty).to receive(:get)
                              .with('http://www.sec.gov/cgi-bin/browse-edgar', query: params)
                              .once
                              .and_return(double(body: xml))

        Sec::Filings.get_xml(Sec::CIKS['GS'])
      end
    end
  end
end
