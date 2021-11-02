describe 'user registration', js: true do
  before do
    visit new_user_registration_path
  end

  scenario 'user submits form without filling it out and is taken to the first required field' do
    expect(page).not_to have_css('#user_user_profile_attributes_name_first:focus')
    click_on 'Sign up'
    expect(page).to have_css('#user_user_profile_attributes_name_first:focus')
  end

  scenario 'user is prompted to accept the terms of use' do
    find('#user_user_profile_attributes_name_first').send_keys('Oedipa')
    find('#user_user_profile_attributes_name_last').send_keys('Maas')
    find('#user_email').send_keys('oedipa@maas.net')
    find('#user_username').send_keys('oedipa')
    find('#user_password').send_keys('trolleron')
    find('#user_password_confirmation').send_keys('trolleron')
    find('#about-you-input').send_keys('investigating Trystero and related matters')
    fill_in_math_captcha('math_captcha')
    click_on 'Sign up'

    expect(page).to have_css('.parsley-required', text: 'Unfortunately, you have to accept the terms first')
  end

  scenario 'user enters a too-short password' do
    find('#user_user_profile_attributes_name_first').send_keys('Oedipa')
    find('#user_user_profile_attributes_name_last').send_keys('Maas')
    find('#user_email').send_keys('oedipa@maas.net')
    find('#user_username').send_keys('oedipa')
    find('#user_password').send_keys('short')
    find('#user_password_confirmation').send_keys('short')
    find('#about-you-input').send_keys('investigating Trystero and related matters')
    fill_in_math_captcha('math_captcha')
    find('#terms_of_use').check
    click_on 'Sign up'
    expect(page).to have_css('.parsley-minlength', text: 'Passwords must be at least 8 characters')
  end

  scenario 'user enters a bad password confirmation' do
    find('#user_user_profile_attributes_name_first').send_keys('Oedipa')
    find('#user_user_profile_attributes_name_last').send_keys('Maas')
    find('#user_email').send_keys('oedipa@maas.net')
    find('#user_username').send_keys('oedipa')
    find('#user_password').send_keys('4Wm45Csff4WbdiC')
    find('#user_password_confirmation').send_keys('a_different_password')
    find('#about-you-input').send_keys('investigating Trystero and related matters')
    fill_in_math_captcha('math_captcha')
    find('#terms_of_use').check
    click_on 'Sign up'
    expect(page).to have_css('.parsley-equalto', text: 'Your password and password confirmation do not match :(')
  end

  scenario 'user is prompted to fill out "about you"' do
    find('#user_user_profile_attributes_name_first').send_keys('Oedipa')
    find('#user_user_profile_attributes_name_last').send_keys('Maas')
    find('#user_email').send_keys('oedipa@maas.net')
    find('#user_username').send_keys('oedipa')
    find('#user_password').send_keys('4Wm45Csff4WbdiC')
    find('#user_password_confirmation').send_keys('4Wm45Csff4WbdiC')
    fill_in_math_captcha('math_captcha')
    find('#terms_of_use').check
    click_on 'Sign up'
    expect(page).to have_css('#about-you-input:focus')
  end
end
