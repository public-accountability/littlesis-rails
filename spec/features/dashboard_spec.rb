require "rails_helper"

describe 'home/dashboard', type: :feature do
  feature 'Using the navigation bar on top of the basic as a regular user' do
    let(:current_user) { create_basic_user }

    before(:each) do
      login_as(current_user, :scope => :user)
      visit '/home/dashboard'
    end

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
end
