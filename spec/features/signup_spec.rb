feature "Signing up for an account", type: :feature do
  let(:user_info) do
    Struct
      .new(:name, :email, :password, :username, :about_you)
      .new(Faker::Name.name, Faker::Internet.email, Faker::Internet.password(min_length: 8), random_username, Faker::Books::Lovecraft.sentence)
  end

  before do
    visit new_user_registration_path
  end

  scenario 'User visits join page' do
    expect(page.status_code).to eq 200
    expect(page).to have_current_path new_user_registration_path

    page_has_selector 'h2', text: 'Get Involved'
    expect(page).to have_text "What are you hoping to use LittleSis for?"
  end

  scenario 'visiting the page in spanish' do
    visit "/join?locale=es"
    expect(page.status_code).to eq 200
    page_has_selector 'h2', text: "Colabora Con Nosotros"
    expect(page).not_to have_text "What are you hoping to use LittleSis for?"
    expect(page).to have_text "¿Para qué espera usar LittleSis?"
  end

  scenario 'Fills out form and signs up' do
    counts = [User.count, UserProfile.count]

    fill_in 'user_user_profile_attributes_name', :with => user_info.name
    fill_in 'user_email', :with => user_info.email
    fill_in 'user_username', :with => user_info.username
    fill_in 'user_password', :with => user_info.password
    fill_in 'user_password_confirmation', :with => user_info.password
    fill_in_math_captcha('math_captcha')
    find(:css, "#terms_of_use").set(true)
    fill_in 'about-you-input', :with => user_info.about_you

    click_button 'Sign up'

    expect([User.count, UserProfile.count]).to eq counts.map { |x| x + 1 }
    expect(page.status_code).to eq 200
    expect(page).to have_current_path join_success_path
    expect(page).not_to have_selector "#signup-errors-alert"

    last_user = User.last
    expect(last_user.newsletter).to be true
  end

  scenario 'Fills out form and signs up with location field' do
    location = 'the center of the earth'

    fill_in 'user_user_profile_attributes_name', :with => user_info.name
    fill_in 'user_email', :with => user_info.email
    fill_in 'user_username', :with => user_info.username
    fill_in 'user_password', :with => user_info.password
    fill_in 'user_password_confirmation', :with => user_info.password
    find(:css, "#terms_of_use").set(true)
    fill_in 'about-you-input', :with => user_info.about_you
    fill_in 'user_user_profile_attributes_location', :with => location
    fill_in_math_captcha('math_captcha')

    click_button 'Sign up'

    expect(UserProfile.last.location).to eql location

    last_user = User.last
    expect(last_user.email).to eq user_info.email
  end

  describe 'Attempting to signup with a username that is already taken' do
    let(:username) { random_username }

    before do
      create_basic_user_with_profile(username: username)
    end

    scenario 'Shows error message regarding the username' do
      counts = [User.count, UserProfile.count]

      fill_in 'user_user_profile_attributes_name', :with => user_info.name
      fill_in 'user_email', :with => user_info.email
      fill_in 'user_username', :with => username # different than the above example
      fill_in 'user_password', :with => user_info.password
      fill_in 'user_password_confirmation', :with => user_info.password
      find(:css, "#terms_of_use").set(true)
      fill_in 'about-you-input', :with => user_info.about_you
      fill_in_math_captcha('math_captcha')

      click_button 'Sign up'

      expect([User.count, UserProfile.count]).to eq counts

      expect(page.status_code).to eq 422
      page_has_selector 'h2', text: 'Get Involved'

      expect(page).to have_css('.alert-danger', text: 'Username has already been taken')
    end
  end

  scenario 'answering the math problem incorrectly' do
    counts = [User.count, UserProfile.count]

    fill_in 'user_user_profile_attributes_name', :with => user_info.name
    fill_in 'user_email', :with => user_info.email
    fill_in 'user_username', :with => user_info.username
    fill_in 'user_password', :with => user_info.password
    fill_in 'user_password_confirmation', :with => user_info.password
    fill_in 'math_captcha[math_captcha_answer]', with: 10_000

    find(:css, "#terms_of_use").set(true)
    fill_in 'about-you-input', :with => user_info.about_you

    click_button 'Sign up'

    expect([User.count, UserProfile.count]).to eq counts
    expect(page.status_code).to eq 200

    expect(page).to have_css('.alert-danger', text: 'Failed to solve the math problem')
  end
end
