describe 'edit entity page', type: :feature, js: true do
  include EntitiesHelper

  let(:user) { create_editor }
  let(:entity) { create(:public_company_entity, last_user_id: user.id) }
  let(:create_external_link) { false }

  before do
    if create_external_link
      ExternalLink.create!(entity_id: entity.id, link_id: wikipedia_name, link_type: 'wikipedia')
    end
    login_as(user, scope: :user)
    visit concretize_edit_entity_path(entity)
  end

  after { logout(:user) }

  feature "updating an entity's fields" do
    let(:new_short_description) { Faker::Lorem.sentence }

    scenario "submitting a new short description and selecting 'just cleaning up'" do
      expect(page).to have_current_path concretize_edit_entity_path(entity)
      page_has_selectors '#actions',
                         '#action-buttons',
                         '#reference-widget'

      page_has_selector '.entity-name2', text: entity.name

      find('input[name="reference[just_cleaning_up]"]').click

      fill_in 'entity_blurb', :with => new_short_description
      click_button 'Update'

      expect(page).to have_current_path concretize_entity_path(entity)
      expect(entity.reload.blurb).to eql new_short_description
    end
  end

  feature 'filling out business data' do
    scenario 'user adds business financial details' do
      expect(entity.business).to be_a(Business)

      within ".edit_entity" do
        find('input[name="reference[just_cleaning_up]"]').click
        fill_in 'Market capitalization', with: 123.0
        fill_in 'Annual profit', with: 10_101
        click_button 'Update'
      end

      within "#action-buttons" do
        click_on "edit"
      end

      expect(page).to have_current_path concretize_entity_path(entity)
      expect(page).to have_field('Market capitalization', with: 123.0)
      expect(page).to have_field('Annual profit', with: 10_101)
    end
  end

  #feature 'changing start date' do
  #  scenario 'setting date to "1 May, 1970"' do
  #    expect(entity.start_date).to eq nil
  #
  #    find('input[name="reference[just_cleaning_up]"]').click
  #
  #    within ".edit_entity" do
  #      fill_in 'entity_start_date', :with => "1 May, 1970"
  #      click_button 'Update'
  #    end
  #
  #    expect(entity.reload.start_date).to eq '1970-05-01'
  #
  #    within "#action-buttons" do
  #      click_on "edit"
  #    end
  #
  #    expect(page).to have_field('Start date', with: '1970-05-01')
  #  end
  #end

  feature 'adding new references', js: true do
    let(:url) { Faker::Internet.unique.url }
    let(:ref_name) { 'reference-name' }
    let(:start_date) { '1950-01-01' }

    scenario 'the url is not yet in the database' do
      document_count = Document.count

      click_button 'reference-widget-create-new-reference'
      fill_in 'reference[url]', :with => url
      fill_in 'reference[name]', :with => ref_name
      click_button 'Update'

      expect(Document.count).to eq (document_count + 1)
      expect(page).to have_current_path concretize_entity_path(entity)
      expect(entity.reload.start_date).to eql start_date
      expect(Reference.last.attributes.slice('referenceable_id', 'referenceable_type'))
        .to eq({ 'referenceable_id' => entity.id, 'referenceable_type' => 'Entity' })
    end

    scenario 'when the url already exists as a document' do
      Document.create!(url: url)
      document_count = Document.count
      click_button 'reference-widget-create-new-reference'
      fill_in 'reference[url]', :with => url
      fill_in 'reference[name]', :with => ref_name
      click_button 'Update'
      expect(Document.count).to eq document_count
      expect(page).to have_current_path concretize_entity_path(entity)
      expect(entity.reload.start_date).to eql start_date
      expect(Reference.last.attributes.slice('referenceable_id', 'referenceable_type'))
        .to eq({ 'referenceable_id' => entity.id, 'referenceable_type' => 'Entity' })
    end
  end

  feature 'external links', js: false do
    let(:user) { create_editor }
    let(:wikipedia_name) { 'example_page' }
    let(:twitter_username) { Faker::Internet.unique.username }

    scenario 'submitting a new wikipedia link and new twitter' do
      external_link_count = ExternalLink.count

      within('#wikipedia_external_link_form') do
        fill_in 'external_link[link_id]', with: wikipedia_name
        click_button 'Submit'
      end

      expect(ExternalLink.count).to eq(external_link_count + 1)
      expect(ExternalLink.last.link_id).to eq wikipedia_name
      expect(ExternalLink.last.entity_id).to eq entity.id
      expect(page).to have_current_path concretize_edit_entity_path(entity)

      within('#twitter_external_link_form') do
        fill_in 'external_link[link_id]', with: twitter_username
        click_button 'Submit'
      end

      expect(ExternalLink.count).to eq(external_link_count + 2)
      expect(Entity.find(entity.id).external_links.count).to eq 2
      expect(ExternalLink.last.link_id).to eq twitter_username
      expect(page).to have_current_path concretize_edit_entity_path(entity)
    end

    feature 'modifying existing external link' do
      let(:create_external_link) { true }

      scenario 'changing the wikipedia page name' do
        external_link_count = ExternalLink.count

        within('#wikipedia_external_link_form') do
          fill_in 'external_link[link_id]', with: 'new_page_name'
          click_button 'Submit'
        end
        expect(ExternalLink.count).to eql external_link_count
        expect(ExternalLink.last.link_id).to eql 'new_page_name'
        expect(ExternalLink.last.entity_id).to eql entity.id
        expect(page).to have_current_path concretize_edit_entity_path(entity)
      end

      scenario 'deleting existing text' do
        external_link_count = ExternalLink.count

        within('#wikipedia_external_link_form') do
          expect(find('input[name="external_link[link_id]"]').value).to eql wikipedia_name
          fill_in 'external_link[link_id]', with: ''
          click_button 'Submit'
        end
        expect(ExternalLink.count).to eql(external_link_count - 1)
        expect(page).to have_current_path concretize_edit_entity_path(entity)
      end
    end
  end
end
