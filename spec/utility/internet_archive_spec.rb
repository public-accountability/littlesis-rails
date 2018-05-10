require 'rails_helper'

describe InternetArchive do
  describe 'save_url' do
    let(:http) { double('http') }
    it 'makes a request to the internet archive to save the url' do
      expect(Net::HTTP).to receive(:start).and_yield(http)
      expect(Net::HTTP::Get).to receive(:new)
                                  .with('/save/https://littlesis.org', InternetArchive::HEADERS)
      expect(http).to receive(:request).once

      InternetArchive.save_url('https://littlesis.org')
    end

    it 'logs waring if encourters erros' do
      expect(Net::HTTP).to receive(:start).and_raise(SocketError)
      expect(Rails.logger).to receive(:warn).once
      expect { InternetArchive.save_url('https://littlesis.org') }
        .not_to raise_error
    end
  end
end
