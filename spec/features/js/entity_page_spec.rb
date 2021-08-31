describe 'Entity page', :sphinx, type: :feature, js: true do
  before { setup_sphinx }
  after { teardown_sphinx }

  context 'with an entity with a summary' do
    let(:entity) { create(:entity_person, summary: Faker::Lorem.paragraph(sentence_count: 10)) }

    scenario 'user toggles the summary to read it' do
      visit person_path(entity)

      within '#entity-summary' do
        expect(page).to have_selector('.summary-full', visible: :hidden)
        expect(page).to have_text 'more »'
        click_on 'more »'

        expect(page).to have_selector('.summary-full', visible: :visible)
        expect(page).to have_text entity.summary

        expect(page).to have_text '« less'
        click_on '« less'
        expect(page).to have_selector('.summary-full', visible: :hidden)
      end
    end
  end

  context 'with multiple relationships to an entity' do
    let(:org) { create(:entity_org, name: 'Limited Inc.') }
    let(:person) { create(:entity_person, name: 'Colander Raclette') }

    before { create_list(:position_relationship, 3, entity: person, related: org) }

    scenario "user toggles to see the hidden relationships" do
      visit org_path(org)

      within '.related_entity' do
        expect(page).to have_selector('.related_entity_name', text: 'Colander Raclette')

        expect(page).to have_text '[+2]'
        expect(page).to have_selector('.collapse', visible: :hidden)

        find('.toggle').click
        expect(page).to have_selector('.collapse', visible: :visible)

        # expect(page).to have_selector('a', text: 'Position', count: 3)

        find('.toggle').click
        expect(page).to have_selector('.collapse', visible: :hidden)
      end
    end
  end

  context 'with a logged in user' do
    let(:user) { create_basic_user }
    let(:person) { create(:entity_person, name: 'Colander Raclette', blurb: 'A human cheese') }

    before { login_as user, scope: :user }
    after { logout(:user) }

    # THESE FAIL ON CIRCLECI BUT NOT LOCALLY
    describe 'Adding and removing tags' do
      before do
        create(:finance_tag)
        create(:real_estate_tag)
      end

      xit 'user adds tags to an entity' do
        visit person_path(person)
        expect(page).to have_css('#tags-container li', count: 0)

        find('#tags-edit-button').click
        find('#entity-tags-modal .select2-container').click
        find('.select2-container--open .select2-results__option', text: 'finance').click
        find('#entity-tags-modal .select2-container').click
        find('.select2-container--open .select2-results__option', text: 'real-estate').click
        find('#entity-tags-modal .modal-header').click
        find('#entity-tags-modal input.btn[type="submit"]').click
        expect(page).to have_css('#tags-container li', count: 2)
      end

      xit 'user removes a tag from an entity' do
        person.add_tag('finance')
        visit person_path(person)
        expect(page).to have_css('#tags-container li', count: 1)

        find('#tags-edit-button').click
        find('.select2-selection__choice[title="finance"] .select2-selection__choice__remove').click
        find('#entity-tags-modal .modal-header').click
        find('#entity-tags-modal input.btn[type="submit"]').click
        expect(page).to have_css('#tags-container li', count: 0)

      end
    end

    describe 'Add entities to lists', :sphinx do
      scenario 'user searches for the list and adds the entity to it' do
        create(:list, name: 'Objectified people')
        visit person_path(person)

        find('#sidebar-lists-container .select2').click
        find('.select2-container--open .select2-search__field').native.send_keys('Objectified')
        find('.select2-container--open .select2-search__field').native.send_keys(:return)
        find('#sidebar-lists-container .select2-selection').click
        find('.select2-container--open .select2-search__field').native.send_keys(:return)
        find('#sidebar-lists-container input[value="add to list"]').click

        expect(page).to have_selector('.alert-success', text: "Added to list 'Objectified people'")
      end
    end
  end
end
