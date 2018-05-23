module RequestExampleMacros
  def json
    JSON.parse(response.body)
  end

  # for whatever reason the updated_at field
  # gets changed in our test environment ever-so-slightly
  def truncate_updated_at(data)
    data.map do |h|
      h['attributes']['updated_at'] = h['attributes']['updated_at'][0, 16]
    end
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
