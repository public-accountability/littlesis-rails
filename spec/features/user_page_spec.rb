require 'rails_helper'

feature 'User Pages' do
  let(:current_user) { create_basic_user }
  let(:user_for_page) { create_basic_user }
  let(:admin) { create_admin_user }
  let(:user) { current_user }
  let(:entity) { create(:entity_person) }
  before do
    login_as(user, scope: :user)
    entity.update!(is_current: true, last_user_id: user_for_page.sf_guard_user_id)
  end
  after { logout(user) }

  feature 'User Page' do
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

  feature 'User Edits Page' do
    let(:url) { "/users/#{user_for_page.username}/edits" }

    context 'logged in as another user' do
      let(:user) { current_user }
      before { visit url }
      denies_access
    end

    context 'logged in as admin' do
      let(:user) { admin }
      before { visit url }
      specify { successfully_visits_page(url) }
    end

    context 'logged in as the user' do
      let(:entities) { Array.new(2) { create(:entity_org) } }
      let(:user) { user_for_page }

      context 'with 2 edits' do
        with_versioning do
          before do
            entities.each { |e| e.update!(blurb: Faker::Dog.meme_phrase) }

            entities.each { |e| e.versions.last.update_columns(whodunnit: user_for_page.id.to_s) }
            visit url
          end

          scenario 'page has table of recent edits' do
            successfully_visits_page(url)
            page_has_selector 'table#user-edits-table'
            page_has_selector '#user-edits-table tbody tr', count: 2
          end
        end
      end
    end # end logged in as the user
  end # end User Edits Page
end
