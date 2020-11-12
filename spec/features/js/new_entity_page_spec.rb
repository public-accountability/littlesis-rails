feature 'New entity page', type: :feature, js: true do
  context 'with a logged in user' do
    let(:user) { create_basic_user }

    before { login_as user, scope: :user }

    after { logout(:user) }

    scenario "user tries to create an entity but sees validation errors" do
      visit new_entity_path

      expect(page).to have_selector('h1', text: 'Add Entity')

      within '#new_entity' do
        fill_in 'entity_name', with: 'Bono'
        find('#entity_name').native.send_keys(:tab)

        expect(page).to have_selector('.alert-warning', text: 'Valid names are at least two words')
      end
    end
  end
end
