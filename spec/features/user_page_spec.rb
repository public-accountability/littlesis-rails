require 'rails_helper'

feature 'User Pages' do
  let(:current_user) { create_basic_user }
  let(:user_for_page) { create_basic_user }
  let(:admin) { create_admin_user }
  let(:user) { current_user }
  let(:entity) { create(:entity_person) }

  let(:create_maps) do
    proc do
      create(:network_map, user_id: user_for_page.sf_guard_user_id, is_private: false)
      create(:network_map, user_id: user_for_page.sf_guard_user_id, is_private: true)
    end
  end

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
      page_has_selector 'small', text: "member since #{user.created_at.strftime('%B %Y')}"
    end

    scenario 'visiting the page via the legacy url' do
      visit "/user/#{user_for_page.username}"
      successfully_visits_page "/users/#{user_for_page.username}"
      page_has_selector 'h1', text: user_for_page.username
    end

    scenario 'visiting a user page as any logged into user' do
      visit "/users/#{user_for_page.id}"
      successfully_visits_page "/users/#{user_for_page.id}"
      page_has_selector 'h1', text: user_for_page.username
      page_has_selector 'div', text: user_for_page.about_me
      page_has_selector '#user-page-recent-updates-table', count: 1
      expect(page).not_to have_selector 'h3', text: 'Permissions'
      expect(page).not_to have_selector 'h3 small a', text: 'view all edits'
      expect(page).not_to have_selector 'h3', text: 'Maps'
    end

    context 'loggin in as an admin' do
      let(:user) { admin }
      before { create_maps.call }

      scenario 'viewing the maps section' do
        visit "/users/#{user_for_page.id}"
        successfully_visits_page "/users/#{user_for_page.id}"
        page_has_selector 'h3', text: 'Maps'
        page_has_selector "#user-page-network-maps-table tr", count: 1
      end
    end

    context 'logged in as the user' do
      let(:user) { user_for_page }

      scenario 'visiting your own user page' do
        visit "/users/#{user_for_page.id}"
        successfully_visits_page "/users/#{user_for_page.id}"
        page_has_selector 'h1', text: user.username
        page_has_selector 'h3', text: 'Permissions'
        expect(page).to have_selector 'h3 small a', text: 'view all edits'
      end

      context 'maps section' do
        before { create_maps.call }

        scenario 'viewing maps section of the users page' do
          visit "/users/#{user_for_page.id}"
          successfully_visits_page "/users/#{user_for_page.id}"
          page_has_selector 'h3', text: 'Maps'
          page_has_selector "#user-page-network-maps-table tr", count: 2
        end
      end
    end

    context 'user is restricted' do
      before do
        user_for_page.update!(is_restricted: true)
        visit "/users/#{user_for_page.username}"
      end

      scenario 'does not show user pages for restircted users' do
        expect(page.status_code).to eq 404
      end

      context 'logged in as admin' do
        let(:user) { admin }

        scenario 'admins can view restricted users pages' do
          successfully_visits_page "/users/#{user_for_page.username}"
        end
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
            entities.each { |e| e.update!(blurb: Faker::Creature::Dog.meme_phrase) }

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
