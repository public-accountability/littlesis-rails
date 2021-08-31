feature 'Adding an entity relationship', :sphinx, type: :feature, js: true do
  let!(:user) { create_basic_user }
  let(:entity) { create(:entity_person, name: 'Brendan Pips') }
  let(:entity2) { create(:entity_person, name: 'Graeme Glamp') }

  before do
    setup_sphinx
    [entity, entity2]
    login_as user, scope: :user
    visit person_path(entity)
  end

  after do
    logout(:user)
    teardown_sphinx
  end

  scenario 'user visits person page, searches for other person and creates a relationship' do
    within '#action-buttons' do
      click_on 'add relationship'
    end
    expect(page).to have_css('h2', text: 'Create a new relationship')

    within '.add-relationship-entity-search-input-group' do
      fill_in 'name-to-search', with: entity2.name
      click_on 'Search'
    end

    within '#results-table' do
      expect(page).to have_text('Graeme Glamp')
      click_on 'select'
    end

    expect(page).to have_css('h3', text: "Creating a new relationship between #{entity.name} and #{entity2.name}")

    within '#category-selection' do
      click_on 'Family'
    end

    within '#reference' do
      click_on 'Create Reference'
      fill_in 'reference-url', with: Faker::Internet.url
      fill_in 'reference-name', with: Faker::Company.name
      click_on 'Create Relationship'
    end

    expect(page).to have_css('h1', text: "Family: #{entity.name}, #{entity2.name}")
    visit person_path(entity)

    within '#relationship_tabs_content' do
      expect(page).to have_text entity2.name
    end
  end
end
