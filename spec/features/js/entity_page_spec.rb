describe 'Entity page', :sphinx, type: :feature, js: true do
  before { setup_sphinx }
  after { teardown_sphinx }

  # context 'with an entity with a summary' do
  #   let(:entity) { create(:entity_person, summary: Faker::Lorem.paragraph(sentence_count: 10)) }

  #   scenario 'user toggles the summary to read it' do
  #     visit person_path(entity)

  #     within '#entity-summary' do
  #       expect(page).to have_selector('.summary-full', visible: :hidden)
  #       expect(page).to have_text 'more »'
  #       click_on 'more »'

  #       expect(page).to have_selector('.summary-full', visible: :visible)
  #       expect(page).to have_text entity.summary

  #       expect(page).to have_text '« less'
  #       click_on '« less'
  #       expect(page).to have_selector('.summary-full', visible: :hidden)
  #     end
  #   end
  # end

  context 'with multiple relationships to an entity' do
    let(:org) { create(:entity_org, name: 'Limited Inc.') }
    let(:person) { create(:entity_person, name: 'Colander Raclette') }

    before { create_list(:position_relationship, 3, entity: person, related: org) }

    scenario "user toggles to see the hidden relationships" do
      visit org_path(org)

      expect(page).to have_selector('.other-entity-name', text: 'Colander Raclette')

      within '.profile-page-relationships' do
        expect(page).to have_text '[+2]'
        expect(page).to have_selector('.collapse', visible: :hidden)
      end

      expect(page).to have_selector('a', text: 'Position', count: 2, visible: :hidden)

      find('.profile-page-relationships span[role="button"]').click
      expect(page).to have_selector('.profile-page-relationships .collapse', visible: :visible)

      expect(page).to have_selector('a', text: 'Position', count: 3, visible: :visible)

      find('.profile-page-relationships span[role="button"]').click
      expect(page).to have_selector('.profile-page-relationships .collapse', visible: :hidden)
      # end
    end
  end

  context 'with a logged in user' do
    let(:user) { create_basic_user }
    let(:person) { create(:entity_person, name: 'Colander Raclette', blurb: 'A human cheese') }

    before { login_as user, scope: :user }
    after { logout(:user) }

    describe 'Adding and removing tags' do
      before do
        Tag.remove_instance_variable(:@lookup) if Tag.instance_variable_defined?(:@lookup)
        create(:finance_tag)
        create(:real_estate_tag)
      end

      after do
        Tag.remove_instance_variable(:@lookup) if Tag.instance_variable_defined?(:@lookup)
      end

      it 'user adds tags to an entity' do
        visit person_path(person)
        expect(page).to have_css('#tags-container li', count: 0)
        expect(find('#edit-tags-modal').visible?).to be false
        # binding.irb
        find('#tags-edit-button').click                                            # click pencil icon

        expect(find('#edit-tags-modal').visible?).to be true
        expect(page).not_to have_selector('.select2-results')
        find('#edit-tags-modal .select2-container').click                        # click inside search modal
        expect(page).to have_selector('.select2-results ul li', count: 2)
        # Add two tags
        find('.select2-container--open .select2-results__option', text: 'finance').click
        find('#edit-tags-modal .select2-container').click
        find('.select2-container--open .select2-results__option', text: 'real-estate').click

        find('#edit-tags-modal .modal-header').click
        find('#edit-tags-modal input.btn[type="submit"]').click
        expect(page).to have_selector('#tags-list li ', count: 2)
      end

      it 'user removes a tag from an entity' do
        person.add_tag('finance')
        visit person_path(person)
        expect(page).to have_css('#tags-container li', count: 1)

        find('#tags-edit-button').click
        find('.select2-selection__choice[title="finance"] .select2-selection__choice__remove').click
        find('#edit-tags-modal .modal-header').click
        find('#edit-tags-modal input.btn[type="submit"]').click
        expect(page).to have_css('#tags-container li', count: 0)
      end
    end

    describe 'Add entities to lists', :sphinx do
      scenario 'user searches for the list and adds the entity to it' do
        create(:list, name: 'Objectified people')
        visit person_path(person)

        find('.sidebar-lists .select2').click
        find('.select2-container--open .select2-search__field').native.send_keys('Objectified')
        find('.select2-container--open .select2-search__field').native.send_keys(:return)
        find('.sidebar-lists .select2-selection').click
        find('.select2-container--open .select2-search__field').native.send_keys(:return)
        find('.sidebar-lists input[value="add to list"]').click

        expect(page).to have_selector('.alert-success', text: "Added to list 'Objectified people'")
      end
    end
  end
end
