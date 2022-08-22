describe 'Merging entities' do
  let(:mode) {}
  let(:user) {}
  let(:merge_request) {}
  let(:source) { create(:merge_source_person) }
  let(:dest) do
    create(:entity_person, :with_person_name).tap do |e|
      e.update_columns(link_count: 10)
    end
  end

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
      let(:user) { create_editor }

      it "navigates to search page from `merge` action button" do
        click_link "merge"
        successfully_visits_page merge_entities_path(mode: :search, source: source.id)
      end
    end

    context "as an admin" do
      let(:user) { create_admin_user }

      it "navigates to search page from `merge` action button" do
        click_link "merge"
        successfully_visits_page merge_entities_path(mode: :search, source: source.id)
      end

      # it "navigates to merge search page from `similar entities` section" do
      #   click_link 'Begin merging process »'
      #   successfully_visits_page merge_path(mode: :search, source: source.id)
      # end
    end
  end

  describe "using merge pages" do
    def should_show_merge_report
      # page_has_selector 'h2', count: 2
      page_has_selector 'h2', text: "It will delete "
      page_has_selector 'h3', text: "This will make the following changes:"
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
        # page_has_selector "textarea[name='justification']", count: 1
        page_has_selector "input.btn[value='Request Merge']", count: 1
        page_has_selector 'a.btn', text: 'Go back'
      end
    end

    def should_commit_merge
      successfully_visits_page entity_path(dest)
      expect(dest.reload.relationships.count).to eq 1
      expect(dest.lists.count).to eq 1
      expect(source.reload.is_deleted).to be true
      expect(source.merged_id).to eq dest.id
    end

    def should_not_commit_merge
      expect(dest.reload.relationships.count).to eq 0
      expect(dest.lists.count).to eq 0
      expect(source.reload.is_deleted).to be false
      expect(source.merged_id).to be_nil
    end

    before do
      mock_similar_entities_service
    end

    context 'when logged in as an editor' do
      let(:user) { create_editor }

      describe 'searching for merge targets' do
        let(:mode) { MergeController::Modes::SEARCH }

        it "allows access" do
          visit merge_entities_path(mode: "search", source: source.id)
          expect(page).to have_http_status :ok
        end
      end

      describe 'requesting a merge' do
        let(:justification) { Faker::Movie.quote }

        it "shows a merge report" do
          visit merge_entities_path(mode: "request", source: source.id, dest: dest.id)
          should_show_merge_report
        end

        it "shows a merge request form" do
          visit merge_entities_path(mode: "request", source: source.id, dest: dest.id)
          should_show_merge_form :request
        end

        describe "clicking `Request Merge`" do
          it "does not commit the merge" do
            visit merge_entities_path(mode: "request", source: source.id, dest: dest.id)
            fill_in 'justification', with: justification
            click_button "Request Merge"
            successfully_visits_page entity_path(source)
            should_not_commit_merge
          end

          it "creates a pending merge request" do
            visit merge_entities_path(mode: "request", source: source.id, dest: dest.id)
            fill_in 'justification', with: justification
            click_button "Request Merge"

            expect(MergeRequest.count).to eq 1
            last = MergeRequest.last
            expect(last.source).to eq source
            expect(last.dest).to eq dest
            expect(last.user).to eq user
            expect(last.status).to eq "pending"
            expect(last.justification).to eq justification
          end
        end
      end

      describe 'executing a merge' do
        let(:query_param) {}

        before do
          visit merge_entities_path(mode: "execute", source: source.id, dest: dest.id)
        end

        denies_access
      end

      describe 'reviewing a merge' do
        let(:query_param) {}

        before do
          visit merge_entities_path(mode: "execute", source: source.id, dest: dest.id)
        end

        denies_access
      end
    end

    context 'as an user with merger permissions' do
      let(:user) { create_collaborator }

      let(:merge_request) do
        create(:merge_request, user: create_editor, source: source, dest: dest)
      end

      describe 'executing a merge' do
        let(:mode) { MergeController::Modes::EXECUTE }
        let(:query_param) {}

        it 'commits the merge when user clicks `Merge`' do
          visit merge_entities_path(mode: "execute", source: source.id, dest: dest.id)
          click_button "Merge"
          should_commit_merge
        end
      end

      describe 'reviewing a merge' do
        let(:mode) { MergeController::Modes::REVIEW }
        let(:query_param) {}

        before do
          visit merge_entities_path(mode: "review", request: merge_request.id)
        end

        denies_access
      end
    end

    context 'as an admin' do
      let(:user) { create_admin_user }

      context 'searching for merge targets' do
        let(:mode) { MergeController::Modes::SEARCH }
        let(:query) { source.name }

        before do
          visit merge_entities_path(mode: "search", query: query, source: source.id)
        end

        it "has a search bar to search for more matches" do
          page_has_selector 'form[action="/entities/merge"]'
          page_has_selector 'input[@value="Search"]'
          page_has_selector "input[@value='#{source.id}']"
        end

        it 'shows a table of last search matches' do
          page_has_selector 'h1', text: "Merge #{source.name} with another person"
        end
      end

      context 'executing a merge' do
        let(:mode) { MergeController::Modes::EXECUTE }
        let(:query_param) {}

        before do
          visit merge_entities_path(mode: "execute", source: source.id, dest: dest.id)
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

        describe "that is pending" do
          it "allows access" do
            merge_request
            visit merge_entities_path(mode: "review", request: merge_request.id)
            expect(page).to have_http_status 200
          end

          it "shows a merge report" do
            merge_request
            visit merge_entities_path(mode: "review", request: merge_request.id)

            should_show_merge_report
            should_show_merge_form :review
          end

          it "shows a description of the merge request" do
            visit merge_entities_path(mode: "review", request: merge_request.id)
            desc = page.find("#user-request-description")
            expect(desc).to have_link username, href: "/users/#{username}"
            expect(desc).to have_text "requested"
            expect(desc).to have_text I18n.l(merge_request.created_at)
          end

          it "shows the user's submitted justification" do
            visit merge_entities_path(mode: "review", request: merge_request.id)
            expect(page).to have_text merge_request.justification
          end

          it "approves merge request when admin clicks `Approve`" do
            visit merge_entities_path(mode: "review", request: merge_request.id)
            click_button "Approve"

            successfully_visits_page entity_path(dest)
            should_commit_merge
            expect(merge_request.reload.status).to eql 'approved'
            expect(merge_request.reviewer).to eql user
          end

          it "denies merge request when admin clicks `Deny`" do
            visit merge_entities_path(mode: "review", request: merge_request.id)
            click_button "Deny"

            successfully_visits_page entity_path(dest)
            should_not_commit_merge
            expect(merge_request.reload.status).to eql 'denied'
            expect(merge_request.reviewer).to eql user
          end
        end

        describe "that has already been approved" do
          before do
            merge_request.approved_by!(user)
            visit merge_entities_path(mode: mode, request: merge_request)
          end

          it "redirects to error page" do
            successfully_visits_page merge_redundant_entities_path(request: merge_request.id)
            expect(page).to have_text "already approved by #{user.username}"
          end
        end

        describe "that has already been denied" do
          before do
            merge_request.denied_by!(user)
            visit merge_entities_path(mode: mode, request: merge_request)
          end

          it "redirects to error page" do
            successfully_visits_page merge_redundant_entities_path(request: merge_request.id)
            expect(page).to have_text "already denied by #{user.username}"
          end
        end
      end
    end
  end
end
