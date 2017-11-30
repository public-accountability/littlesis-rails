module RequestExampleMacros
  def json
    JSON.parse(response.body)
  end
end

module RequestGroupMacros
  def denies_access
    it 'denies access' do
      expect(response).to have_http_status(403)
    end
  end
end
