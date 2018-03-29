module RequestExampleMacros
  def json
    JSON.parse(response.body)
  end

  def redirects_to_path(path)
    expect(response).to have_http_status 302
    expect(response.location).to include path
  end
end

module RequestGroupMacros
  def as_basic_user
    let(:basic_user) { create_really_basic_user }
    before(:each) { login_as(basic_user, :scope => :user) }
    context 'when logged in as a basic user' do
      yield
    end
    after(:each) { logout(:user) }
  end

  def denies_access
    it 'denies access' do
      expect(response).to have_http_status(403)
    end
  end

  def renders_the_edit_page
    it 'renders the "edit" page' do
      expect(response).to have_http_status 200
      expect(response).to render_template(:edit)
    end
  end

  def redirects_to_dashboard
    it 'redirects to dashboard and sets notice' do
      expect(response).to have_http_status 302
      expect(response.location).to include home_dashboard_path
    end
  end
end
