require 'rails_helper'

feature 'maps index page' do
  let(:other_user) { create_really_basic_user }
  let(:user) { create_really_basic_user }
  let(:admin) { create_admin_user }
  let(:regular_map) { create(:network_map, user_id: user.sf_guard_user_id) }
  let(:private_map) { create(:network_map, is_private: true, user_id: user.sf_guard_user_id) }
  let(:featured_map) { create(:network_map, is_featured: true, user_id: user.sf_guard_user_id) }
  let!(:maps) { [regular_map, private_map, featured_map] }

  feature 'navigating to "/maps"' do
    before { visit '/maps' }
    scenario 'redirecting to /maps/featured' do
      successfully_visits_page '/maps/featured'
    end
  end

  feature 'viewing all maps' do
    before { visit '/maps/all'; }

    scenario 'visiting /maps/all' do
      successfully_visits_page '/maps/all'
      page_has_selector '#maps-table'
      page_has_selector '#maps-table tbody tr', count: 2 # skips private maps
    end
  end

  feature 'viewing featured maps' do
    before do
      # create a featured, yet private map which should be exluded
      create(:network_map, is_featured: true, is_private: true, user_id: user.sf_guard_user_id)
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
      page_has_selector '#maps-table tbody tr', count: 2 # skips private maps
    end
  end

  feature 'viewing private maps in list if logged in' do
    before do
      login_as(user, scope: :user)
      # create a network map of a different
      create(:network_map, is_private: true, user_id: create_really_basic_user.sf_guard_user_id)
      visit '/maps/all'
    end
    after { logout(user) }

    scenario 'visiting /maps/all' do
      successfully_visits_page '/maps/all'
      page_has_selector '#maps-table tbody tr', count: 3 # includes private maps
    end
  end
end
