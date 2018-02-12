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

  def redirects_to_dashboard
    it 'redirects to dashboard and sets notice' do
      expect(response).to have_http_status 302
      expect(response.location).to include home_dashboard_path
    end
  end
end
