require 'email_spec'
require 'email_spec/rspec'

feature 'List deletion request & review' do
  let(:requester) { create_really_basic_user }
  let(:admin) { create_admin_user }
  let(:list) { create(:list) }

  describe 'reviewing a deletion request', :run_jobs do
    let(:req) { create(:list_deletion_request, user: requester, type: 'ListDeletionRequest', list: list) }
    let(:user) { admin }

    context 'with an admin account' do
      before do
        login_as admin
      end

      context 'with a deletion request notification email' do
        before do
          NotificationMailer.list_deletion_request_email(req).deliver_later
        end

        scenario 'the link in the email takes me to the review page' do
          email = open_last_email
          expect(email).to have_subject("List deletion request received for #{list.name}")
          link = URI.parse(links_in_email(email).first)
          visit link.path
          expect(page).to have_text "The following #{req.description} was requested by #{requester.username}"
        end

        context 'when on the deletion request review page' do
          before do
            visit review_deletion_requests_list_path(id: req.id)
          end

          scenario 'I can click to deny the deletion request' do # rubocop:disable RSpec/ExampleLength
            expect(page).to have_text('This deletion will remove the following list from the database')

            within '#list-deletion-action-buttons' do
              click_on 'Deny'
            end

            expect(req.reload.status).to eq 'denied'
            within '.alert-success' do
              expect(page).to have_text 'Deletion request denied'
            end
          end

          scenario 'I can click to approve the deletion request' do # rubocop:disable RSpec/ExampleLength
            expect(page).to have_text('This deletion will remove the following list from the database')

            within '#list-deletion-action-buttons' do
              click_on 'Approve'
            end

            expect(req.reload.status).to eq 'approved'
            within '.alert-success' do
              expect(page).to have_text 'Deletion request approved'
            end
          end
        end
      end
    end
  end

  describe 'requesting a deletion' do
    context 'with a non-admin account' do
      let(:user) { requester }

      before do
        login_as user, scope: :user
        visit list_path(list)
        click_link 'request removal'
      end

      it 'shows the deletion request page' do
        successfully_visits_page new_deletion_requests_list_path(list_id: list.id)
      end

      it 'shows information about the list to be deleted' do
        within '#deletion-report' do
          expect(page).to have_text 'will remove the following list'
          expect(page).to have_link list.name, href: list_path(list)
          expect(page).to have_text list.description
        end
      end

      it 'shows submit button and text area' do
        within '#list-deletion-request-form' do
          expect(page).to have_css('textarea#justification')
          expect(page).to have_button 'Request Deletion'
        end
      end

      describe 'validations' do
        context 'without filling in the form' do
          it 'raises a validation error' do
            expect { click_on 'Request Deletion' }
              .to raise_error(
                ActionController::ParameterMissing,
                'param is missing or the value is empty: justification'
              )
          end
        end
      end

      describe 'submitting a valid form', :run_jobs do
        let(:justification) { Faker::Movie.quote }

        before do
          fill_in 'justification', with: justification
        end

        it 'emails admins with a link to review the request' do
          click_on 'Request Deletion'
          email = open_last_email
          expect(email).to have_subject("List deletion request received for #{list.name}")
          expect(email).to have_body_text("Justification for deletion: #{justification}")
        end

        it 'does not delete the list' do
          expect { click_on 'Request Deletion' }.not_to change(List, :count)
        end

        it 'creates a pending deletion request' do # rubocop:disable RSpec/ExampleLength
          expect { click_on 'Request Deletion' }.to change(ListDeletionRequest, :count).by(1)
          expect(ListDeletionRequest.last)
            .to have_attributes(
              status: 'pending',
              user: requester,
              list: list,
              justification: justification
            )
        end
      end
    end
  end
end
