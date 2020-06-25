describe 'edit entity page', type: :feature do
  let(:user) { create_really_basic_user }
  let(:entity) { create(:public_company_entity, last_user_id: user.id) }

  context 'when user is not logged in' do
    before { visit edit_entity_path(entity) }

    redirects_to_login_page
  end

  context 'when user is logged in' do
    let(:setup) { -> {} }

    before do
      setup.call
      login_as(user, scope: :user)
      visit edit_entity_path(entity)
    end

    after { logout(user) }

    feature 'viewing the edit entity page' do
      scenario 'displays header, action buttons, and edit references panel' do
        expect(page.status_code).to eq 200
        expect(page).to have_current_path edit_entity_path(entity)
        page_has_selectors '#actions',
                           '#action-buttons',
                           '#edit-references-panel',
                           '#reference_url',
                           '#reference_name'
        page_has_selector '#entity-name', text: entity.name
      end
    end

    feature "updating an entity's fields" do
      let(:new_short_description) { Faker::Lorem.sentence }

      context "when selecting 'just cleaning up' " do
        scenario 'submitting a new short description' do
          check 'reference_just_cleaning_up'
          fill_in 'entity_blurb', :with => new_short_description
          click_button 'Update'

          expect(page).to have_current_path entity_path(entity)
          expect(entity.reload.blurb).to eql new_short_description
        end
      end

      context 'when filling out business data' do
        scenario 'user adds business financial details' do
          expect(entity.business).to be_a(Business)

          within ".edit_entity" do
            check 'reference_just_cleaning_up'
            fill_in 'Market capitalization', with: 123
            fill_in 'Assets', with: 432
            fill_in 'Net income', with: 999
            fill_in 'Annual profit', with: 10_101
            click_button 'Update'
          end

          within "#action-buttons" do
            click_on "edit"
          end

          expect(page).to have_current_path edit_entity_path(entity)
          expect(page).to have_field('Market capitalization', with: 123)
          expect(page).to have_field('Assets', with: 432)
          expect(page).to have_field('Net income', with: 999)
          expect(page).to have_field('Annual profit', with: 1_0101)
        end
      end

      context 'adding a new reference' do
        let(:url) { Faker::Internet.unique.url }
        let(:ref_name) { 'reference-name' }
        let(:start_date) { '1950-01-01' }
        let(:update_entity) do
          proc {
            click_button 'create-new-reference-btn'
            fill_in 'reference_url', :with => url
            fill_in 'reference_name', :with => ref_name
            fill_in 'entity_start_date', :with => start_date
            click_button 'Update'
          }
        end

        def verify_redirect_and_start_date
          expect(page).to have_current_path entity_path(entity)
          expect(entity.reload.start_date).to eql start_date
        end

        def verify_last_reference
          expect(Reference.last.attributes.slice('referenceable_id', 'referenceable_type'))
            .to eql({ 'referenceable_id' => entity.id, 'referenceable_type' => 'Entity' })
        end

        context 'when the url does not exist as a document' do
          before do
            @document_count = Document.count
            update_entity.call
          end

          scenario 'updating the start date' do
            verify_redirect_and_start_date
            verify_last_reference
            expect(Document.count).to eql(@document_count + 1)
          end
        end

        context 'when the url already exists as a document' do
          before do
            Document.create!(url: url)
            @document_count = Document.count
            update_entity.call
          end

          scenario 'updating the start date' do
            verify_redirect_and_start_date
            verify_last_reference
            expect(Document.count).to eql(@document_count)
          end
        end

      end # end context adding a new reference
    end # end updating an entity's fields

    describe 'external links' do
      let(:user) { create_basic_user }
      let(:wikipedia_name) { 'example_page' }
      let(:twitter_username) { Faker::Internet.unique.username }
      let!(:external_link_count) { ExternalLink.count }

      feature 'adding external links' do
        scenario 'submiting a new wikipedia link and new twitter' do
          within('#wikipedia_external_link_form') do
            fill_in 'external_link[link_id]', with: wikipedia_name
            click_button 'Submit'
          end

          expect(ExternalLink.count).to eql(external_link_count + 1)
          expect(ExternalLink.last.link_id).to eql wikipedia_name
          expect(ExternalLink.last.entity_id).to eql entity.id
          expect(page).to have_current_path edit_entity_path(entity)

          within('#twitter_external_link_form') do
            fill_in 'external_link[link_id]', with: twitter_username
            click_button 'Submit'
          end

          expect(ExternalLink.count).to eql(external_link_count + 2)
          expect(Entity.find(entity.id).external_links.count).to eq 2
          expect(ExternalLink.last.link_id).to eql twitter_username
          expect(page).to have_current_path edit_entity_path(entity)

        end
      end

      feature 'modifying existing external link' do
        let(:setup) do
          -> { ExternalLink.create!(entity_id: entity.id, link_id: wikipedia_name, link_type: 'wikipedia') }
        end

        scenario 'changing the wikipedia page name' do
          external_link_count = ExternalLink.count

          within('#wikipedia_external_link_form') do
            fill_in 'external_link[link_id]', with: 'new_page_name'
            click_button 'Submit'
          end
          expect(ExternalLink.count).to eql external_link_count
          expect(ExternalLink.last.link_id).to eql 'new_page_name'
          expect(ExternalLink.last.entity_id).to eql entity.id
          expect(page).to have_current_path edit_entity_path(entity)
        end
      end

      feature 'removing an external link' do
        let(:setup) do
          -> { ExternalLink.create!(entity_id: entity.id, link_id: wikipedia_name, link_type: 'wikipedia') }
        end

        scenario 'deleting existing text' do
          external_link_count = ExternalLink.count

          within('#wikipedia_external_link_form') do
            expect(find('input[name="external_link[link_id]"]').value).to eql wikipedia_name
            fill_in 'external_link[link_id]', with: ''
            click_button 'Submit'
          end
          expect(ExternalLink.count).to eql(external_link_count - 1)
          expect(page).to have_current_path edit_entity_path(entity)
        end

      end
    end # end external links
  end # end context user is logged in
end
