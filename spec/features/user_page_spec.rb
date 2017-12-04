require 'rails_helper'

feature 'User Pages' do
  let(:current_user) { create_basic_user }
  let(:user_for_page) { create_basic_user }
  let(:user) { current_user }
  let(:entity) { create(:entity_person) }
  before do
    login_as(user, scope: :user)
    entity.update!(is_current: true, last_user_id: user_for_page.sf_guard_user_id)
  end
  after { logout(user) }

  scenario 'visiting the page via the user name' do
    visit "/users/#{user_for_page.username}"
    successfully_visits_page "/users/#{user_for_page.username}"
    page_has_selector 'h1', text: user_for_page.username
  end

  scenario 'visiting the page via the legacy url' do
    visit "/user/#{user_for_page.username}"
    successfully_visits_page "/users/#{user_for_page.username}"
    page_has_selector 'h1', text: user_for_page.username
  end

  scenario 'visiting a user page as a logged into user' do
    visit "/users/#{user_for_page.id}"
    successfully_visits_page "/users/#{user_for_page.id}"
    page_has_selector 'h1', text: user_for_page.username
    page_has_selector 'div', text: user_for_page.about_me
    page_has_selector 'div.dashboard-entity', count: 1
    expect(page).not_to have_selector 'h3', text: 'Permissions'
  end

  context 'logged in as the user' do
    let(:user) { user_for_page }
    scenario 'visiting your own user page' do
      visit "/users/#{user.id}"
      successfully_visits_page "/users/#{user.id}"
      page_has_selector 'h1', text: user.username
      page_has_selector 'h3', text: 'Permissions'
    end
  end
end
