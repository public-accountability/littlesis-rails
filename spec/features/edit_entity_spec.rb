require 'rails_helper'

describe 'edit enity page', type: :feature do
  let(:user) { create_really_basic_user }
  let(:entity) { create(:entity_org, last_user_id: user.sf_guard_user.id) }

  context 'user is not logged in' do
    before { visit edit_entity_path(entity) }
    redirects_to_login_page
  end

  feature 'Visiting the edit page entity page' do
    before do
      login_as(user, scope: :user)
      visit edit_entity_path(entity)
    end
    after { logout(user) }

    scenario 'shows header and action buttons' do
      expect(page.status_code).to eq 200
      expect(page).to have_current_path edit_entity_path(entity)
      page_has_selectors '#actions', '#action-buttons'
    end
  end
end
