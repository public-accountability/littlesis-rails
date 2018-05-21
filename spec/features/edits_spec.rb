require 'rails_helper'

feature 'recent edits page' do
  let(:user) { create_basic_user }

  before { login_as(user, scope: :user) }
  after { logout(:user) }

  context 'with 3 edits, one from "system"' do
    before do
      create(:entity_person).tap { |e| e.update!(last_user_id: user.sf_guard_user_id) }
      create(:entity_org).tap { |e| e.update!(last_user_id: user.sf_guard_user_id) }
      create(:entity_org).tap { |e| e.update!(last_user_id: 1) }
    end

    scenario 'visiting the recent edits page' do
      visit '/edits'
      successfully_visits_page '/edits'
      page_has_selector '#container table', count: 1
      page_has_selector '#container table tbody tr', count: 2
    end
  end
end
