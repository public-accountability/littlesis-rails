describe 'Oligrapher' do
  let(:other_user) { create_really_basic_user }
  let(:user) { create_really_basic_user }
  let(:admin) { create_admin_user }
  let(:regular_map) { create(:network_map, user_id: user.id) }
  let(:private_map) { create(:network_map, is_private: true, user_id: user.id) }
  let(:featured_map) { create(:network_map, is_featured: true, user_id: user.id) }
  let(:maps) { [regular_map, private_map, featured_map] }

  before { maps }

  describe 'oligrapher creation page' do
    before { login_as(user, scope: :user) }
    after { logout(user) }

    it 'uses new oligrapher path' do
      visit new_oligrapher_path
      successfully_visits_page new_oligrapher_path
    end
  end

  describe 'Anonyomous users can view embedded regular maps' do
    before { visit oligrapher_path(regular_map) }

    specify { successfully_visits_page oligrapher_path(regular_map) }
  end

  describe 'Users can view their own private maps' do
    before do
      login_as(user, scope: :user)
      visit oligrapher_path(private_map)
    end

    after { logout(user) }

    it 'map page is viewable' do
      successfully_visits_page oligrapher_path(private_map)
    end
  end

  describe 'other users cannot view private maps' do
    before { login_as(other_user, scope: :user) }
    after { logout(other_user) }

    it 'access is denied to map page' do
      visit oligrapher_path(private_map)
      expect(page).to have_http_status :not_found
    end
  end
end
