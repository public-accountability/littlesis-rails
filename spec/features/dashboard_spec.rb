require "rails_helper"

describe 'home/dashboard', type: :feature do
  let(:current_user) { create_basic_user }

  feature 'Using the navigation bar on top of the basic as a regular user' do
    before(:each) do
      login_as(current_user, :scope => :user)
      visit '/home/dashboard'
    end
    after { logout(:user) }

    scenario 'nav dropdown' do
      expect(page.status_code).to eq 200
      expect(page).to have_current_path home_dashboard_path

      expect(page).to have_selector 'ul.nav li a', text: current_user.username
      expect(page).to have_selector 'ul.nav li a', text: 'Tags'
      expect(page).to have_selector 'ul.nav li a', text: 'Donate'
      # verifing that networks have been removed:
      expect(page).not_to have_selector 'ul.nav li a', text: 'United States'
    end
  end

  feature 'viewing map thumbnails' do
    before { login_as(current_user, :scope => :user) }
    after { logout(:user) }

    context 'User has one map, with a nil thumbnail' do
      before do
        create(:network_map,
               user_id: current_user.sf_guard_user_id,
               thumbnail: nil,
               is_private: false)
        visit '/home/dashboard'
      end

      scenario 'pages has default map image' do
        successfully_visits_page home_dashboard_path
        page_has_selector 'img.dashboard-map-thumbnail', count: 1
      end
    end
  end
end
