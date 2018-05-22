require "rails_helper"

describe 'home/dashboard', type: :feature do
  let(:current_user) { create_basic_user }
  before { login_as(current_user, :scope => :user) }
  after { logout(:user) }

  feature 'Using the navigation bar on top of the basic as a regular user' do
    before { visit '/home/dashboard' }

    scenario 'nav dropdown' do
      expect(page.status_code).to eq 200
      expect(page).to have_current_path home_dashboard_path

      expect(page).to have_selector 'ul.nav li a', text: current_user.username
      expect(page).to have_selector 'ul.nav li a', text: 'Tags'
      expect(page).to have_selector 'ul.nav li a', text: 'Donate'
      expect(page).to have_selector 'ul.nav li a', text: 'Help'
      # verifing that networks have been removed:
      expect(page).not_to have_selector 'ul.nav li a', text: 'United States'
    end
  end

  feature 'viewing map thumbnails' do
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

  feature 'viewing dashboard bulletins' do
    before do
      DashboardBulletin.create!(title: 'title A', markdown: '# contentA')
      DashboardBulletin
        .create!(title: 'title B', markdown: '# contentB')
        .tap { |b| b.update_column(:created_at, 1.day.ago) }
      visit '/home/dashboard'
    end

    let(:a_selector) { '#dashboard-bulletins .panel:nth-child(1)' }
    let(:b_selector) { '#dashboard-bulletins .panel:nth-child(2)' }

    scenario 'user can see 2 bulletins' do
      successfully_visits_page home_dashboard_path
      page_has_selector 'div.panel', count: 2

      expect(find("#{a_selector} .panel-heading")).to have_text('title A')
      expect(find("#{a_selector} .panel-body h1")).to have_text('contentA')
      expect(find("#{b_selector} .panel-heading")).to have_text('title B')
      expect(find("#{b_selector} .panel-body h1")).to have_text('contentB')
    end
  end
end
