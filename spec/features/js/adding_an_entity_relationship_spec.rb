feature 'Adding an entity relationship', :sphinx, type: :feature, js: true do
  let!(:user) { create_editor }
  let(:entity) { create(:entity_person, name: 'Brendan Pips') }
  let(:entity2) { create(:entity_person, name: 'Graeme Glamp') }

  let(:url) { Faker::Internet.url }
  let(:name) { Faker::Company.name }

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

    fill_in 'add-relationship-search-input', with: entity2.name
    click_on 'add-relationship-search-button'

    within '#add-relationship-results-table' do
      expect(page).to have_text('Graeme Glamp')
      click_on 'select'
    end

    expect(page).to have_text('Creating a new relationship between')

    find("#add-relationship-relationship-category-4").click
    fill_in 'add-relationship-url-input', with: url
    fill_in 'add-relationship-name-input', with: name
    find("#add-relationship-submit-button").click

    expect(current_path).to include "/relationships/"
    expect(page).to have_css 'h1', text: /Family/

    expect(Relationship.last.attributes.slice('entity1_id', 'entity2_id', 'category_id'))
      .to eq('entity1_id' => entity.id, 'entity2_id' => entity2.id, 'category_id' => 4)

    expect(Reference.last.document.slice('name', 'url'))
      .to eq('name' => name, 'url' => url)
  end
end
