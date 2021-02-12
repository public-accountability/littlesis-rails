feature 'Creating entities from list members page', :sphinx, type: :feature, js: true do
  let(:list_owner) { create_basic_user }
  let(:list) { create(:list, name: 'The Crying of Lot 49', creator_user_id: list_owner.id, last_user_id: list_owner.id) }
  let(:oedipa) { create(:entity_person, name: 'Oedipa Maas') }
  let(:mucho) { create(:entity_person, name: 'Mucho Maas') }

  before do
    setup_sphinx do
      [oedipa, mucho].each do |person|
        ListEntity.create!(list_id: list.id, entity_id: person.id)
      end
    end

    login_as list_owner, scope: :user
    visit members_list_path(list)
  end

  after do
    logout(:user)
    teardown_sphinx
  end

  scenario 'searching for a non-existent entity then creating it' do
    within '.list-actions' do
      fill_in 'add entity', with: 'Pierce Inverarity'
      expect(page).to have_css('.add-entity-suggestion', text: 'No entities found')
      click_on 'create it now'
    end

    expect(page).to have_css('h1', text: "Create entity for #{list.name} list")

    within '#new_entity_form' do
      fill_in 'Name*', with: 'Pierce Inverarity'
      fill_in 'Short description', with: 'Real estate tycoon'
      choose 'Person'
      find('input[value="BusinessPerson"]').check
      click_on 'Add'
    end

    expect(page).to have_css('.alert-success', text: 'Pierce Inverarity added to The Crying of Lot 49 list')
  end

  scenario 'trying to create an entity with an invalid form' do
    within '.list-actions' do
      fill_in 'add entity', with: 'Pierce Inverarity'
      expect(page).to have_css('.add-entity-suggestion', text: 'No entities found')
      click_on 'create it now'
    end

    expect(page).to have_css('h1', text: "Create entity for #{list.name} list")

    within '#new_entity_form' do
      fill_in 'Name*', with: 'Pierce'
      click_on 'Add'
    end

    expect(page).to have_text("Could not save entity: Primary ext can't be blank.")
    expect(page).to have_text('Valid names are at least two words')
  end
end
