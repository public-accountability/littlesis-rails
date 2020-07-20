describe NginxLogService do
  let(:logfile) { Rails.root.join('spec/testdata/sample_nginx.log').to_s }

  describe 'insert_file' do
    it 'parses log file and inserts data into web_requests' do
      expect { NginxLogService.insert_file(logfile) }.to change(WebRequest, :count).by(4)
    end

    it 'can be safely used multiple times with the same file' do
      expect { 2.times { NginxLogService.insert_file(logfile) } }
        .to change(WebRequest, :count).by(4)
    end
  end
end
