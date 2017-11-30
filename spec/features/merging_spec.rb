require 'rails_helper'

feature 'Merging entities' do
  let(:user) { create_merger_user }
  let(:source_entity) { create(:entity_person) }

  before(:each)  { login_as(user, scope: :user) }
  after(:each) { logout(:user) }

  context 'as a regular user' do
    let(:user) { create_basic_user }
    before { visit "/tools/merge?source=#{source_entity.id}" }
    denies_access
  end

  context 'viewing the search table' do
    before { visit "/tools/merge?source=#{source_entity.id}" }

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
      page_has_selector '#merge-entities-form'
      page_has_selector "input.btn[value='Merge']", count: 1
      page_has_selector 'a.btn', text: 'Go back'
      page_has_selector 'a.btn', text: 'Dashboard'
    end

    scenario 'clicking to merge the two entities' do
      expect(dest.relationships.count).to eql 0
      expect(dest.lists.count).to eql 0

      successfully_visits_page "/tools/merge"

      click_button "Merge"

      successfully_visits_page entity_path(dest)

      expect(dest.reload.relationships.count).to eql 1
      expect(dest.lists.count).to eql 1
      expect(source.reload.is_deleted).to be true
      expect(source.merged_id).to eql dest.id
    end
  end
end
