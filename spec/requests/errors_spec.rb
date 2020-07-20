describe 'Errors' do
  describe 'Filing bug reports' do
    context 'when submitting a valid bug report' do
      let(:params) do
        { 'page' => "https://littlesis.org/bug_report", 'email' => Faker::Internet.email }
      end

      it 'sends notification email' do
        expect(NotificationMailer).to receive(:bug_report_email).and_return(double(deliver_later: nil))
        post '/bug_report', params: params
        expect(response.body).to include CGI.escapeHTML(ErrorsController::THANK_YOU_NOTICE)
      end
    end

    context 'when a spam bot submits a bug report' do
      let(:params) do
        { 'page' => Faker::Internet.url, 'email' => Faker::Internet.email }
      end

      it 'does not send an notification email' do
        expect(NotificationMailer).not_to receive(:bug_report_email)
        post '/bug_report', params: params
        expect(response.body).to include CGI.escapeHTML(ErrorsController::YOU_ARE_SPAM)
      end
    end
  end
end
