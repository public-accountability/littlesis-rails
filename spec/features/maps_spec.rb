describe 'Maps' do
  let(:other_user) { create_really_basic_user }
  let(:user) { create_really_basic_user }
  let(:admin) { create_admin_user }
  let(:regular_map) { create(:network_map, user_id: user.id) }
  let(:private_map) { create(:network_map, is_private: true, user_id: user.id) }
  let(:featured_map) { create(:network_map, is_featured: true, user_id: user.id) }
  let(:maps) { [regular_map, private_map, featured_map] }

  before { maps }

  describe 'viewing a map page' do
    before { visit map_path(regular_map) }

    it 'redirects to oligrapher map' do
      expect(page.current_path).to eq oligrapher_path(regular_map)
    end

    # it 'has oligrapher js with username and link' do
    #   expect(page.html).to include "/js/oligrapher/oligrapher-#{NetworkMap::OLIGRAPHER_VERSION}.js"
    #   expect(page.html).to include "/js/oligrapher/oligrapher_littlesis_bridge-#{NetworkMap::OLIGRAPHER_VERSION}.js"
    #   expect(page.html).to include "{ name: \"#{user.username}\""
    #   expect(page.html).to include "url: \"https://littlesis.org/users/#{user.username}\" }"
    # end
  end

  describe 'oligrapher creation page' do
    before { login_as(user, scope: :user) }
    after { logout(user) }

    it 'uses new oligrapher path' do
      visit new_map_path
      successfully_visits_page new_oligrapher_path
    end
  end

  xdescribe 'Anonyomous users can view embedded regular maps' do
    before { visit map_path(regular_map) }

    specify { successfully_visits_page map_path(regular_map) }
  end

  xdescribe 'Users can view their own private maps' do
    before do
      login_as(user, scope: :user)
      visit map_path(private_map)
    end

    after { logout(admin) }

    it 'map page is viewable' do
      successfully_visits_page map_path(private_map)
    end
  end

  describe 'other users cannot view private maps' do
    before { login_as(other_user, scope: :user) }

    after { logout(admin) }

    it 'access is denied to map page' do
      visit map_path(private_map)
      expect(page).to have_http_status :forbidden
    end

    it 'access is denied to embedded v2 maps' do
      visit embedded_v2_map_path(private_map)
      expect(page).to have_http_status :forbidden
    end

    it 'access is denied to embedded v1 maps' do
      visit embedded_map_path(private_map)
      expect(page).to have_http_status :forbidden
    end

    it 'access is denied to map_json' do
      visit map_json_map_path(private_map)
      expect(page).to have_http_status :forbidden
    end
  end

  feature 'navigating to "/maps"' do
    before { visit '/maps' }

    scenario 'redirecting to /maps/featured' do
      successfully_visits_page '/maps/featured'
    end
  end

  feature 'viewing all maps' do
    before { visit '/maps/all' }

    scenario 'visiting /maps/all' do
      successfully_visits_page '/maps/all'
      page_has_selector '#maps-table'
      page_has_selector '#maps-table thead th', count: 3
      expect(page).not_to have_selector '.star' # non-admins don't have this option
      page_has_selector '#maps-table tbody tr', count: 2 # skips private maps
    end
  end

  feature 'viewing featured maps' do
    before do
      # create a featured, yet private map which should be exluded
      create(:network_map, is_featured: true, is_private: true, user_id: user.id)
      visit '/maps/featured'
    end

    scenario 'visiting /maps/featured' do
      successfully_visits_page '/maps/featured'
      page_has_selector '#maps-table'
      page_has_selector '#maps-table tbody tr', count: 1 # only one featured map
    end
  end

  feature 'admins cannot view private maps' do
    before do
      login_as(admin, scope: :user)
      visit '/maps/all'
    end

    after { logout(admin) }

    scenario 'visiting /maps/all as an admin' do
      successfully_visits_page '/maps/all'
      page_has_selector '.star', count: 1
      page_has_selector '.not-star', count: 1
      page_has_selector '#maps-table tbody tr', count: 2 # skips private maps
    end
  end

  feature 'viewing private maps in list if logged in' do
    before do
      login_as(user, scope: :user)
      # create a network map of a different
      create(:network_map, is_private: true, user_id: create_really_basic_user.id)
      visit '/maps/all'
    end

    after { logout(user) }

    scenario 'visiting /maps/all' do
      successfully_visits_page '/maps/all'
      page_has_selector '#maps-table tbody tr', count: 3 # includes private maps
    end
  end

  feature 'setting and removing featured maps' do
    context 'when logged in as an admin' do
      before { login_as(admin, scope: :user) }

      after { logout(admin) }

      scenario 'adding feature a map' do
        visit '/maps/all'
        page_has_selector '.star', count: 1
        page.find('.not-star').first(:xpath, ".//..").click
        successfully_visits_page '/maps/all'
        page_has_selector '.star', count: 2
      end

      scenario 'removing is featured from a map' do
        visit '/maps/all'
        page_has_selector '.star', count: 1
        page.find('.star').first(:xpath, ".//..").click
        successfully_visits_page '/maps/all'
        expect(page).not_to have_selector '.featured-map-star'
      end
    end
  end
end
