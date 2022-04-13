describe 'User Settings' do
  let(:current_user) do
    create(
      :user,
      email: 'what@ever.org',
      username: 'shrubrocketeer',
      password: 'unobtainium'
    )
  end

  let(:other_user) do
    create(
      :user,
      email: 'who@ever.org',
      username: 'fencefowl'
    )
  end

  before do
    other_user
    login_as(current_user, scope: :user)
    visit '/settings'
  end

  scenario 'user updates own username' do
    expect(page).to have_css('h2', text: 'Edit your settings')

    within '#edit_user' do
      fill_in 'Username', with: 'waftcap'
      fill_in 'Current password', with: 'unobtainium'
      click_on 'Update'
    end

    expect(page).to have_css('.alert-success', text: 'You updated your account successfully.')
    expect(current_user.reload.username).to eq 'waftcap'
  end

  scenario 'user tries to set their username to one that is taken' do
    expect(page).to have_css('h2', text: 'Edit your settings')

    within '#edit_user' do
      fill_in 'Username', with: 'fencefowl'
      fill_in 'Current password', with: 'unobtainium'
      click_on 'Update'
    end

    expect(page).to have_text('Username has already been taken')
    expect(current_user.reload.username).to eq 'shrubrocketeer'
  end

  scenario 'setting language to Spanish', js: true do
    expect(current_user.settings.language).to eq :en
    expect(page).to have_css('h2', text: 'Edit your settings')
    page.select 'Spanish', from: 'user-settings-language'
    expect(current_user.reload.settings.language).to eq :es
    # expect(page).to have_css('h2', text: "Edita tu configuración")
  end
end
