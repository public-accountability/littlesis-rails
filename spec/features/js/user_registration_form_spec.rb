describe 'user registration', js: true do
  describe_unless_on_ci 'user registration', js: true do
    scenario 'user submits form without filling it out and is taken to the first required field' do
      visit "/join"
      expect(page).not_to have_css('#user_user_profile_attributes_name:focus')
      click_on 'Sign up'
      expect(page).to have_css('#user_user_profile_attributes_name:focus')
    end

    scenario 'user creates an account' do
      visit "/join"
      fill_in 'user_user_profile_attributes_name', with: 'Oedipa Maas'
      fill_in 'user_email', with: 'oedipa@maas.net'
      fill_in 'user_username', with: 'oedipa'
      fill_in 'user_password', with: 'trolleron'
      fill_in 'user_password_confirmation', with: 'trolleron'
      fill_in 'about-you-input', with: 'investigating Trystero and related matters'
      fill_in_math_captcha('math_captcha')
      find("#terms_of_use").set(false)
      find('#user-registration-submit-button').click
      expect(page).to have_text("An email with a confirmation link is on the way.", wait: 10)
      expect(User.last.username).to eq 'oedipa'
      expect(User.last.email).to eq 'oedipa@maas.net'
    end
  end

  # scenario 'user is prompted to accept the terms of use' do
  #   visit "/join"
  #   fill_in 'user_user_profile_attributes_name', with: 'Oedipa Maas'
  #   fill_in 'user_email', with: 'oedipa@maas.net'
  #   fill_in 'user_username', with: 'oedipa'
  #   fill_in 'user_password', with: 'trolleron'
  #   fill_in 'user_password_confirmation', with: 'trolleron'
  #   fill_in 'about-you-input', with: 'investigating Trystero and related matters'
  #   fill_in_math_captcha('math_captcha')
  #   find("#terms_of_use").set(false)
  #   # click_on 'Sign up'
  #   find('#user-registration-submit-button').click
  #   expect(page).to have_css('.parsley-required', text: 'Unfortunately, you have to accept the terms first')
  # end

  # scenario 'user enters a too-short password' do
  #   visit "/join"
  #   find('#user_user_profile_attributes_name').send_keys('Oedipa Maas')
  #   find('#user_email').send_keys('oedipa@maas.net')
  #   find('#user_username').send_keys('oedipa')
  #   find('#user_password').send_keys('short')
  #   find('#user_password_confirmation').send_keys('short')
  #   find('#about-you-input').send_keys('investigating Trystero and related matters')
  #   fill_in_math_captcha('math_captcha')
  #   find('#terms_of_use').check
  #   # click_on 'Sign up'
  #   find('input[name="submit"]')
  #   expect(page).to have_css('.parsley-minlength', text: 'Passwords must be at least 8 characters')
  # end

  # scenario 'user enters a bad password confirmation' do
  #   visit "/join"
  #   find('#user_user_profile_attributes_name').send_keys('Oedipa Maas')
  #   find('#user_email').send_keys('oedipa@maas.net')
  #   find('#user_username').send_keys('oedipa')
  #   find('#user_password').send_keys('4Wm45Csff4WbdiC')
  #   find('#user_password_confirmation').send_keys('a_different_password')
  #   find('#about-you-input').send_keys('investigating Trystero and related matters')
  #   fill_in_math_captcha('math_captcha')
  #   find('#terms_of_use').check
  #   click_on 'Sign up'
  #   expect(page).to have_css('.parsley-equalto', text: 'Your password and password confirmation do not match')
  # end
end
