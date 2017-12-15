require 'rails_helper'

feature 'Merging entities' do
  let(:mode) {}
  let(:source) { create(:merge_source_person) }
  let(:dest) { create(:entity_person, :with_person_name) }
  let(:dest_param) { "&dest=#{dest.id}"}
  let(:query) { "foobar" }
  let(:query_param) { "&query=#{query}" }

  before { login_as(user, scope: :user) }
  after { logout(:user) }

  describe "clicking on `Merge this entity` link" do
    before { visit entity_path source }

    context "as a non-admin user" do
      let(:user) { create(:really_basic_user) }

      it "is not possible" do
        expect(page).not_to have_link("Merge this entity")
      end
    end

    context "as an admin" do
      let(:user) { create(:admin_user) }

      it "navigates to the merge searchn page" do
        click_link "Merge this entity"
        successfully_visits_page tools_merge_path(mode: :search, source: source.id)
      end
    end
  end

  describe "using merge pages" do

    before do
      allow(Entity::Search).to receive(:similar_entities).and_return([dest])
      visit tools_merge_path(mode: mode,
                             source: source.id,
                             dest: dest.id,
                             query: query)
    end

    context 'as a non-admin user' do
      let(:user) { create(:really_basic_user) }

      context 'searching for merge targets' do
        let(:mode) { ToolsController::MergeModes::SEARCH }
        let(:dest_param) {}

        it "allows access" do
          expect(page).to have_http_status 200
        end
      end

      context 'requesting a merge' do
        let(:mode) { ToolsController::MergeModes::REQUEST }
        let(:query_param) {}

        it "allows access" do
          expect(page).to have_http_status 200
        end
      end

      context 'executing a merge' do
        let(:mode) { ToolsController::MergeModes::EXECUTE }
        let(:query_param) {}

        denies_access
      end

      context 'reviewing a merge' do
        let(:mode) { ToolsController::MergeModes::REVIEW }
        let(:query_param) {}

        denies_access
      end
    end

    context 'as an admin' do
      let(:user) { create(:admin_user) }

      context 'searching for merge targets' do
        let(:mode) { ToolsController::MergeModes::SEARCH }
        let(:query) { source.name }

        it "has a search bar to search for more matches" do
          page_has_selector 'form[action="/tools/merge"]'
          page_has_selector 'input[@value="search"]'
          page_has_selector "input[@value='#{source.id}']"
        end

        it 'shows a table of last search matches' do
          page_has_selector 'h1', text: "Merge #{source.name} with another person"
        end

        it "is impossible to test the contents of the table b/c it is in javascript"
        # ^-- i wanted this as a sanity check to make sure the row i was trying to click
        # `merge` in (see below) was actually there (@aguestuser)

        it "is impossible to test clicking `merge` b/c the button is in javascript"
        # ^-- i broke this by changing the URL at which the merge report page lives
        # and thus, to which this button should submit, and and wanted to add a test
        # to catch that breakage, but could not (@aguestuser)
      end

      context 'requesting a merge' do
        let(:mode) { ToolsController::MergeModes::REQUEST }
        let(:query_param) {}

        it "raises a custom error?"
      end

      context 'executing a merge' do
        let(:mode){ ToolsController::MergeModes::EXECUTE }
        let(:query_param) {}
        let(:list) { create(:list) }
        let(:source){ create(:merge_source_person) }

        scenario 'viewing the report page' do
          page_has_selector 'h2', count: 2
          page_has_selector 'h2', text: "It will delete "
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
end
