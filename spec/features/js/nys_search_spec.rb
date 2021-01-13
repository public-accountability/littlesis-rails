feature 'NYS search', :sphinx, type: :feature, js: true do
  let(:user) { create_admin_user }
  let(:orgs) { [] }

  before do
    login_as user, scope: :user

    setup_sphinx do
      4.times { orgs << create(:entity_org, name: Faker::Company.name) }
    end
  end

  after do
    logout(:user)
    teardown_sphinx
  end

  scenario 'searching for a PAC' do
    visit pacs_path

    expect(page).to have_css('h5', text: 'Find the LittleSis Entity of the PAC')

    within '#entity-search-form' do
      fill_in 'entity-search', with: orgs.last.name
      click_on 'Search'
    end

    within '#table-container' do
      expect(page).to have_css('a', text: orgs.last.name)
    end
  end
end
