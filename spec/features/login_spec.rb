describe 'Login', type: :feature do
  let!(:entity) { create(:entity_org) }

  context 'with a logged-out user' do
    let!(:user) { create_basic_user(password: 'password') }

    after { logout(:user) }

    scenario 'user clicks login and is taken to the dashboard' do
      visit org_path(entity)

      within '#main-navbar-container' do
        click_on 'Login'
      end

      expect(page).to have_css('h2', text: 'Log in')

      within '#new_user' do
        fill_in 'email', with: user.email
        fill_in 'password', with: 'password'
        click_on 'Log in'
      end

      expect(page).to show_success('Signed in successfully.')

      expect(page).to have_css('h1', text: 'LittleSis Dashboard')
    end

    scenario 'user is redirected via login to the entity edit page' do
      visit org_path(entity)

      expect(page).to have_css('#entity-name', text: entity.name)

      within '#action-buttons' do
        click_on 'edit'
      end

      expect(page).to show_warning('You need to sign in or sign up before continuing.')

      within '#new_user' do
        fill_in 'email', with: user.email
        fill_in 'password', with: 'password'
        click_on 'Log in'
      end

      expect(page).to show_success('Signed in successfully.')

      expect(page).to have_css('form.edit_entity')
    end
  end
end
