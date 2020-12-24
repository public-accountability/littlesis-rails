feature 'recent edits page' do
  let(:user) { create_basic_user }

  before { login_as(user, scope: :user) }

  after { logout(:user) }

  context 'with 3 edits, one from "system"' do
    before do
      with_versioning_for(user) do
        create(:entity_person)
        create(:entity_org)
      end
      with_versioning_for(User.system_user) do
        create(:entity_org)
      end
    end

    scenario 'visiting the recent edits page' do
      visit '/edits'
      successfully_visits_page '/edits'
      page_has_selector '#recent-edits-row table', count: 1
      page_has_selector '#recent-edits-row table tbody tr', count: 2
    end
  end
end
