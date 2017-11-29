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
      # puts page.html
      successfully_visits_page '/tools/merge'
      page_has_selector 'h1', text: "Merge #{source_entity.name} with another entity"
      page_has_selector 'form[action="/tools/merge"]'
    end
  end

  feature 'merging two people together' do

    let(:list) { create(:list) }
    let!(:source) do
      person = create(:entity_person, :with_person_name)
      person.add_extension('BusinessPerson')
      ListEntity.create!(list_id: list.id, entity_id: person.id)
      Relationship.create!(category_id: 1, entity: person, related: create(:entity_org))
      person
    end
    let!(:dest) { create(:entity_person, :with_person_name) }
    before { visit "/tools/merge?source=#{source.id}&dest=#{dest.id}"  }

    scenario 'viewing the report page' do
      page_has_selector 'h2', count: 2
      page_has_selector 'h2', text: "It will delete "#{dest.name} (#{dest.id}) from the database"
      page_has_selector 'h4', text: "This will make the following changes:"
      page_has_selector '#merge-report li', count: 4
      page_has_selector 'li', text: "Transfer 1 relationships"
    end

    scenario 'clicking to merge the two entities' do
      successfully_visits_page "/tools/merge?source=#{source.id}&dest=#{dest.id}"
    end
  end
end
