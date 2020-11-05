feature 'Entity page', type: :feature, js: true do
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
        expect(page).to have_selector('a', text: 'Position', count: 3)

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

    scenario "user edits the entity's blurb" do
      visit person_path(person)

      within '#editable-blurb' do
        expect(page).to have_selector('#entity-blurb-text', text: 'A human cheese')

        expect(page).to have_selector('#entity-blurb-pencil', visible: :hidden)
        find('#entity-blurb-text').hover
        expect(page).to have_selector('#entity-blurb-pencil', visible: :visible)
        find('#entity-blurb-pencil').click

        find('#entity-blurb-text input').fill_in with: 'A human utensil'
        find('#entity-blurb-text input').native.send_keys(:return)

        expect(page).to have_selector('#entity-blurb-text', text: 'A human utensil')
      end
    end

    context 'with a list', :sphinx do
      let!(:list) { create(:list, name: 'Objectified people') }

      before { setup_sphinx { list } }

      after { teardown_sphinx }

      scenario 'user searches for the list and adds the entity to it' do
        visit person_path(person)

        find('#sidebar-lists-container .select2').click
        find('.select2-search__field').native.send_keys('Objectified')
        find('.select2-search__field').native.send_keys(:return)
        find('.select2-selection').click
        find('.select2-search__field').native.send_keys(:return)
        find('#sidebar-lists-container input[value="add to list"]').click

        expect(page).to have_selector('.alert-success', text: "Added to list 'Objectified people'")
      end
    end
  end
end
