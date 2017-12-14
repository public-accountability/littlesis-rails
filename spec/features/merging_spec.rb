require 'rails_helper'

feature 'Merging entities' do
  let(:mode) {}
  let(:source) { create(:entity_person) }
  let(:dest) { create(:entity_person) }
  let(:query) { 'foobar' }

  before(:each) do
    login_as(user, scope: :user)
    visit "/tools/merge?mode=#{mode}&source=#{source.id}&dest=#{dest.id}&query=#{query}"
  end

  after(:each) { logout(:user) }

  context 'as a non-admin user' do
    let(:user) { create(:really_basic_user) }

    context 'searching for merge targets' do
      let(:mode) { ToolsController::MergeModes::SEARCH }

      it "allows access" do
        expect(page).to have_http_status 200
      end
    end

    context 'requesting a merge' do
      let(:mode) { ToolsController::MergeModes::REQUEST }

      it "allows access" do
        expect(page).to have_http_status 200
      end
    end

    context 'executing a merge' do
      let(:mode) { ToolsController::MergeModes::EXECUTE }
      denies_access
    end

    context 'reviewing a merge' do
      let(:mode) { ToolsController::MergeModes::REVIEW }
      denies_access
    end
  end

  context 'as an admin' do
    let(:user) { create(:admin_user) }

    context 'searching for merge targets' do
      let(:mode) { ToolsController::MergeModes::SEARCH }

      it 'shows a table of entities with similar names as merge source' do
        successfully_visits_page '/tools/merge'
        page_has_selector 'h1', text: "Merge #{source.name} with another entity"
        page_has_selector 'form[action="/tools/merge"]'
      end
    end

    context 'requesting a merge' do
      let(:mode) { ToolsController::MergeModes::REQUEST }

      it "raises a custom error?"
    end

    context 'executing a merge' do

      let(:mode){ ToolsController::MergeModes::EXECUTE }
      let(:list) { create(:list) }
      let!(:source) do
        person = create(:entity_person, :with_person_name)
        person.add_extension('BusinessPerson')
        ListEntity.create!(list_id: list.id, entity_id: person.id)
        Relationship.create!(category_id: 1, entity: person, related: create(:entity_org))
        person
      end
      let!(:dest) { create(:entity_person, :with_person_name) }

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

    context 'reviewing a merge' do
      let(:mode) { ToolsController::MergeModes::REVIEW }

      it "allows access" do
        expect(page).to have_http_status 200
      end
    end
  end
end
