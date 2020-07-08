describe WebRequest do
  describe 'nullify_identifying_data' do
    let!(:recent_request) { create(:web_request, time: 1.day.ago) }
    let!(:old_request) { create(:web_request, time: 10.days.ago) }

    it 'removes ip address and user agent data from old requests' do
      WebRequest.nullify_identifying_data
      expect(recent_request.reload.remote_address).not_to be nil
      expect(recent_request.reload.user_agent).not_to be nil
      expect(old_request.reload.remote_address).to be nil
      expect(old_request.reload.user_agent).to be nil
    end
  end
end
