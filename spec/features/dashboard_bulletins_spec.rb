require 'rails_helper'

feature 'DashboardBulletins', type: :feature do
  before { login_as(user, :scope => :user) }
  after { logout(:user) }

  context 'as a regular user' do
    let(:user) { create_really_basic_user }
    before { visit '/dashboard_bulletins/new' }
    denies_access
  end

  context 'as an admin user' do
    let(:user) { create_admin_user }
    before { visit '/dashboard_bulletins/new' }
    successfully_visits_page('/dashboard_bulletins/new')
  end
end
