require 'rails_helper'

feature 'Merging entities' do
  let(:mode) {}
  let(:user) {}
  let(:merge_request) {}
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

    def should_show_merge_report
      page_has_selector 'h2', count: 2
      page_has_selector 'h2', text: "It will delete "
      page_has_selector 'h4', text: "This will make the following changes:"
      page_has_selector '#merge-report li', count: 4
      page_has_selector 'li', text: "Transfer 1 relationships"
    end

    def should_show_merge_form(mode)
      page_has_selector '#merge-entities-form'
      case mode
      when :execute
        page_has_selector "input.btn[value='Merge']", count: 1
        page_has_selector 'a.btn', text: 'Go back'
        page_has_selector 'a.btn', text: 'Dashboard'
      when :review
        page_has_selector "input.btn[value='Approve']", count: 1
        page_has_selector "input.btn[value='Deny']", count: 1
      end
    end

    def should_commit_merge
      successfully_visits_page entity_path(dest)

      expect(dest.reload.relationships.count).to eql 1
      expect(dest.lists.count).to eql 1
      expect(source.reload.is_deleted).to be true
      expect(source.merged_id).to eql dest.id
    end

    def should_not_commit_merge
      successfully_visits_page entity_path(source)

      expect(dest.reload.relationships.count).to eql 0
      expect(dest.lists.count).to eql 0
      expect(source.reload.is_deleted).to be false
      expect(source.merged_id).to be_nil
    end

    before do
      allow(Entity::Search).to receive(:similar_entities).and_return([dest])
      visit tools_merge_path(mode:    mode,
                             source:  source&.id,
                             dest:    dest&.id,
                             query:   query,
                             request: merge_request&.id)
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

        before do
          expect(dest.relationships.count).to eql 0
          expect(dest.lists.count).to eql 0
        end
        
        it 'shows a merge report' do
          should_show_merge_report
          should_show_merge_form :execute
        end

        it 'commits the merge when user clicks `Merge`' do
          click_button "Merge"
          should_commit_merge
        end
      end

      context 'reviewing a merge' do
        let(:mode) { ToolsController::MergeModes::REVIEW }
        let(:requesting_user) { create(:really_basic_user) }
        let(:username) { requesting_user.username }
        let(:merge_request) { create(:merge_request,
                                     user: requesting_user,
                                     source: source,
                                     dest: dest) }
        
        it "allows access" do
          expect(page).to have_http_status 200
        end

        it "shows a merge report" do
          should_show_merge_report
          should_show_merge_form :review
        end

        it "shows a review description" do
          desc = page.find("#review-description")
          expect(desc).to have_link username, "/users/#{username}"
          expect(desc).to have_text "requested"
          expect(desc).to have_text LsDate.pretty_print(merge_request.created_at)
        end

        it "approves merge request when admin clicks `Approve`" do
          click_button "Approve"
          should_commit_merge
          expect(merge_request.reload.status).to eql 'approved'
          expect(merge_request.reviewer).to eql user
        end

        it "denies merge request when admin clicks `Deny`" do
          click_button "Deny"
          should_not_commit_merge
          expect(merge_request.reload.status).to eql 'denied'
          expect(merge_request.reviewer).to eql user
        end
      end
    end
  end
end
