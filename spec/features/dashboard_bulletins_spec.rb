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
    let(:title) { Faker::Book.title }
    let(:markdown) { Faker::Markdown.headers }

    before { visit '/dashboard_bulletins/new' }

    successfully_visits_page('/dashboard_bulletins/new')

    scenario 'adding a new bulletins' do
      fill_in 'dashboard_bulletin_title', :with => title
      fill_in 'editable-markdown', :with => markdown
      click_button 'Create'

      expect(DashboardBulletin.count).not_to eql 0
      expect(DashboardBulletin.last.markdown).to eql markdown

      successfully_visits_page('/home/dashboard')
    end
  end
end
