describe InternetArchive do
  describe 'save_url' do
    it 'makes a request to the internet archive to save the url' do
      allow(Rails.env).to receive(:production?).and_return(true)

      response = instance_double("Net::HTTPRedirection").tap do |r|
        allow(r).to receive(:is_a?).with(Net::HTTPRedirection).and_return(true)
        allow(r).to receive(:[]).with('location').and_return('https://...')
      end

      expect(Net::HTTP).to receive(:get_response).with(kind_of(URI)).and_return(response)

      expect(Rails.logger).to receive(:info).with(/Saved to internet archive/)

      InternetArchive.save_url('https://littlesis.org')
    end

    it 'logs warning when response is not a redirect' do
      allow(Rails.env).to receive(:production?).and_return(true)

      response = instance_double("Net::HTTPUnauthorized").tap do |r|
        allow(r).to receive(:is_a?).with(Net::HTTPRedirection).and_return(false)
      end

      expect(Net::HTTP).to receive(:get_response).with(kind_of(URI)).and_return(response)

      expect(Rails.logger).to receive(:warn).once
      InternetArchive.save_url('https://littlesis.org')
    end
  end
end
