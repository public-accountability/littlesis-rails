feature 'User registration form', type: :feature, js: true do
  before do
    visit new_user_registration_path
  end

  scenario 'user submits form without filling it out and is taken to the first required field' do
    within '#new_user' do
      click_on 'Sign up'
    end
    expect(page).to have_css('#user_user_profile_attributes_name_first:focus')
  end

  scenario 'user is prompted to accept the terms of use' do
    within '#new_user' do
      fill_in 'First Name', with: 'Oedipa'
      fill_in 'Last Name', with: 'Maas'
      fill_in 'Email', with: 'oedipa@maas.net'
      fill_in 'Username', with: 'oedipa'
      fill_in 'Password (Minimum 8 letters)', with: 'trolleron'
      fill_in 'Password confirmation', with: 'volauvent'
      fill_in 'about-you-input', with: 'investigating Trystero and related matters'
      fill_in_math_captcha('math_captcha')

      alert = accept_alert do
        click_on 'Sign up'
      end
      expect(alert).to eq 'Unfortunately, you have to accept the terms first'
    end
  end

  scenario 'user enters a too-short password' do
    within '#new_user' do
      fill_in 'First Name', with: 'Oedipa'
      fill_in 'Last Name', with: 'Maas'
      fill_in 'Email', with: 'oedipa@maas.net'
      fill_in 'Username', with: 'oedipa'
      fill_in 'Password (Minimum 8 letters)', with: 'wamp'
      fill_in 'Password confirmation', with: 'wamp'
      fill_in 'about-you-input', with: 'investigating Trystero and related matters'
      fill_in_math_captcha('math_captcha')
      find('#terms_of_use').check

      alert = accept_alert do
        click_on 'Sign up'
      end
      expect(alert).to eq 'Please ensure that your password is 8 or more characters long!'
    end
  end

  scenario 'user enters a bad password confirmation' do
    within '#new_user' do
      fill_in 'First Name', with: 'Oedipa'
      fill_in 'Last Name', with: 'Maas'
      fill_in 'Email', with: 'oedipa@maas.net'
      fill_in 'Username', with: 'oedipa'
      fill_in 'Password (Minimum 8 letters)', with: 'wampwamp'
      fill_in 'Password confirmation', with: 'pwampwam'
      fill_in 'about-you-input', with: 'investigating Trystero and related matters'
      fill_in_math_captcha('math_captcha')
      find('#terms_of_use').check

      alert = accept_alert do
        click_on 'Sign up'
      end
      expect(alert).to eq 'Your password and password confirmation do not match :('
    end
  end

  scenario 'user is prompted to fill out "about you"' do
    within '#new_user' do
      fill_in 'First Name', with: 'Oedipa'
      fill_in 'Last Name', with: 'Maas'
      fill_in 'Email', with: 'oedipa@maas.net'
      fill_in 'Username', with: 'oedipa'
      fill_in 'Password (Minimum 8 letters)', with: 'wampwamp'
      fill_in 'Password confirmation', with: 'wampwamp'
      fill_in_math_captcha('math_captcha')
      find('#terms_of_use').check

      click_on 'Sign up'
    end

    expect(page).to have_css('#about-you-input:focus')
  end
end
