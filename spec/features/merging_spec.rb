feature 'Merging entities' do
  let(:mode) {}
  let(:user) {}
  let(:merge_request) {}
  let(:source) { create(:merge_source_person) }
  let(:dest) { create(:entity_person, :with_person_name) }
  let(:query) { "foobar" }

  def mock_similar_entities_service
    allow(SimilarEntitiesService).to receive(:new)
                                       .and_return(double(:similar_entities => [dest]))
  end

  before do
    mock_similar_entities_service
    login_as(user, scope: :user)
  end

  after { logout(:user) }

  describe "navigating to merge pages from an entity profile page" do
    before { visit entity_path source }

    context "as a non-admin user" do
      let(:user) { create_basic_user }

      it "navigates to search page from `merge` action button" do
        click_link "merge"
        successfully_visits_page merge_path(mode: :search, source: source.id)
      end
    end

    context "as an admin" do
      let(:user) { create_admin_user }

      it "navigates to search page from `merge` action button" do
        click_link "merge"
        successfully_visits_page merge_path(mode: :search, source: source.id)
      end

      # it "navigates to merge search page from `similar entities` section" do
      #   click_link 'Begin merging process »'
      #   successfully_visits_page merge_path(mode: :search, source: source.id)
      # end
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
      case mode
      when :execute
        page_has_selector '.merge-entities-form', count: 1
        page_has_selector "input[name='mode'][value='execute']", count: 1
        page_has_selector "input[name='source'][value='#{source.id}']", count: 1
        page_has_selector "input[name='dest'][value='#{dest.id}']", count: 1
        page_has_selector "input.btn[value='Merge']", count: 1
        page_has_selector 'a.btn', text: 'Go back'
        page_has_selector 'a.btn', text: 'Dashboard'
      when :review
        page_has_selector '.merge-entities-form', count: 2
        page_has_selector "input[name='mode'][value='review']", count: 2
        page_has_selector "input[name='request'][value='#{merge_request.id}']", count: 2
        page_has_selector "input.btn[value='Approve']", count: 1
        page_has_selector "input[name='decision'][value='approved']", count: 1
        page_has_selector "input.btn[value='Deny']", count: 1
        page_has_selector "input[name='decision'][value='denied']", count: 1
      when :request
        page_has_selector '.merge-entities-form', count: 1
        page_has_selector "input[name='mode'][value='request']", count: 1
        page_has_selector "input[name='source'][value='#{source.id}']", count: 1
        page_has_selector "input[name='dest'][value='#{dest.id}']", count: 1
        page_has_selector "textarea[name='justification']", count: 1
        page_has_selector "input.btn[value='Request Merge']", count: 1
        page_has_selector 'a.btn', text: 'Go back'
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
      expect(dest.reload.relationships.count).to eql 0
      expect(dest.lists.count).to eql 0
      expect(source.reload.is_deleted).to be false
      expect(source.merged_id).to be_nil
    end

    before do
      mock_similar_entities_service

      visit merge_path(mode:    mode,
                       source:  source&.id,
                       dest:    dest&.id,
                       query:   query,
                       request: merge_request&.id)
    end

    context 'as a non-admin user' do
      let(:user) { create_basic_user }

      context 'searching for merge targets' do
        let(:mode) { MergeController::Modes::SEARCH }
        let(:dest_param) {}

        it "allows access" do
          expect(page).to have_http_status :ok
        end

        it "is impossible to test displaying search results because it is in javascript"
        it "is impossible to test if clicking `merge` goes to correct page  b/c javascript"
      end

      context 'requesting a merge' do
        let(:mode) { MergeController::Modes::REQUEST }
        let(:query_param) {}
        let(:justification) { Faker::Movie.quote }

        it "shows a merge report" do
          should_show_merge_report
        end

        it "shows a merge request form" do
          should_show_merge_form :request
        end

        describe "clicking `Request Merge`" do
          let(:last) { MergeRequest.last }
          let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

          before do
            expect(dest.relationships.count).to eql 0
            expect(dest.lists.count).to eql 0
            expect(MergeRequest.count).to eql 0

            allow(NotificationMailer).to receive(:merge_request_email).and_return(message_delivery)
            allow(message_delivery).to receive(:deliver_later)

            fill_in 'justification', with: justification
            click_button "Request Merge"
          end

          it "does not commit the merge" do
            successfully_visits_page entity_path(source)
            should_not_commit_merge
          end

          it "creates a pending merge request" do
            expect(MergeRequest.count).to eq 1
            expect(last.source).to eql source
            expect(last.dest).to eql dest
            expect(last.user).to eql user
            expect(last.status).to eql "pending"
            expect(last.justification).to eql justification
          end

          it "does not end merge request emailsl" do
            expect(NotificationMailer).not_to have_received(:merge_request_email)
            expect(message_delivery).not_to have_received(:deliver_later)
          end
        end
      end

      context 'executing a merge' do
        let(:mode) { MergeController::Modes::EXECUTE }
        let(:query_param) {}

        denies_access
      end

      context 'reviewing a merge' do
        let(:mode) { MergeController::Modes::REVIEW }
        let(:query_param) {}

        denies_access
      end
    end

    context 'as an user with merger permissions' do
      let(:user) do
        create_collaborator
      end

      context 'executing a merge' do
        let(:mode) { MergeController::Modes::EXECUTE }
        let(:query_param) {}

        it 'commits the merge when user clicks `Merge`' do
          click_button "Merge"
          should_commit_merge
        end
      end

      context 'reviewing a merge' do
        let(:mode) { MergeController::Modes::REVIEW }
        let(:query_param) {}

        denies_access
      end
    end

    context 'as an admin' do
      let(:user) { create_admin_user }

      context 'searching for merge targets' do
        let(:mode) { MergeController::Modes::SEARCH }
        let(:query) { source.name }

        it "has a search bar to search for more matches" do
          page_has_selector 'form[action="/merge"]'
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

      context 'executing a merge' do
        let(:mode) { MergeController::Modes::EXECUTE }
        let(:query_param) {}

        before do
          expect(dest.relationships.count).to eql 0
          expect(dest.lists.count).to eql 0
        end

        it 'shows a merge report' do
          should_show_merge_report
        end

        it "shows a merge execution form" do
          should_show_merge_form :execute
        end

        it 'commits the merge when user clicks `Merge`' do
          click_button "Merge"
          should_commit_merge
        end
      end

      context 'reviewing a merge request' do
        let(:mode) { MergeController::Modes::REVIEW }
        let(:requesting_user) { create_basic_user }
        let(:username) { requesting_user.username }
        let(:merge_request) do
          create(:merge_request, user: requesting_user, source: source, dest: dest)
        end

        context "that is pending" do

          it "allows access" do
            expect(page).to have_http_status 200
          end

          it "shows a merge report" do
            should_show_merge_report
            should_show_merge_form :review
          end

          it "shows a description of the merge request" do
            desc = page.find("#user-request-description")
            expect(desc).to have_link username, href: "/users/#{username}"
            expect(desc).to have_text "requested"
            expect(desc).to have_text I18n.l(merge_request.created_at)
          end

          it "shows the user's submitted justification" do
            expect(page).to have_text merge_request.justification
          end

          it "approves merge request when admin clicks `Approve`" do
            click_button "Approve"

            successfully_visits_page entity_path(dest)
            should_commit_merge
            expect(merge_request.reload.status).to eql 'approved'
            expect(merge_request.reviewer).to eql user
          end

          it "denies merge request when admin clicks `Deny`" do
            click_button "Deny"

            successfully_visits_page entity_path(dest)
            should_not_commit_merge
            expect(merge_request.reload.status).to eql 'denied'
            expect(merge_request.reviewer).to eql user
          end
        end

        context "that has already been approved" do
          before do
            merge_request.approved_by!(user)
            visit merge_path(mode: mode, request: merge_request)
          end

          it "redirects to error page" do
            successfully_visits_page merge_redundant_path(request: merge_request.id)
            expect(page).to have_text "already approved by #{user.username}"
          end
        end

        context "that has already been denied" do
          before do
            merge_request.denied_by!(user)
            visit merge_path(mode: mode, request: merge_request)
          end

          it "redirects to error page" do
            successfully_visits_page merge_redundant_path(request: merge_request.id)
            expect(page).to have_text "already denied by #{user.username}"
          end
        end
      end
    end
  end
end
