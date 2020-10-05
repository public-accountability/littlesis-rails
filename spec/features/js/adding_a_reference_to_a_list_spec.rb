feature 'Adding a reference to a list', type: :feature, js: true do
  let(:list_owner) { create_basic_user }
  let(:list) { create(:list, name: 'All people who have ever lived', creator_user_id: list_owner.id, last_user_id: list_owner.id) }

  before do
    login_as list_owner, scope: :user
    visit members_list_path(list)
  end

  after do
    logout(:user)
  end

  scenario 'adding a reference via the sources tab' do
    within '#list-tab-menu' do
      click_on 'Sources'
    end

    click_on 'Add a new source'

    within '#add-reference-modal' do
      expect(page).to have_css('h4', text: 'Add a new reference')
      fill_in 'URL*', with: 'http://listofallpeopleever.org'
      fill_in 'Display Name*', with: 'List of all people ever'
      click_on 'Submit'
    end

    within '#list-sources' do
      expect(page).to have_text 'List of all people ever'
    end
  end
end
