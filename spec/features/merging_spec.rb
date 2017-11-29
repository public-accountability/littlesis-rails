require 'rails_helper'

feature 'Merging entities' do
  let(:user) { create_bulker_user }
  let(:source_entity) { create(:entity_person) }

  before(:each)  { login_as(user, scope: :user) }
  after(:each) { logout(:user) }

  context 'viewing the search table' do
    before do
      visit "/tools/merge?source=#{source_entity.id}"
    end

    scenario 'page contains a table with potential entities to merge into' do
      successfully_visits_page '/tools/merge'
      page_has_selector '#entity-name', text: source_entity.name
    end
  end
end
