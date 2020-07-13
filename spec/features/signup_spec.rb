feature "Signing up for an account", type: :feature do
  let(:user_info) do
    Struct
      .new(:first_name, :last_name, :email, :password, :username, :about_you)
      .new(Faker::Name.first_name, Faker::Name.last_name, Faker::Internet.email, Faker::Internet.password(min_length: 8), random_username, Faker::Books::Lovecraft.sentence)
  end

  before do
    visit new_user_registration_path
  end

  scenario 'User visits join page' do
    expect(page.status_code).to eq 200
    expect(page).to have_current_path new_user_registration_path

    page_has_selector 'h2', text: 'Get Involved!'
    page_has_selector 'h3', text: 'Become an analyst!'
    expect(page).to have_text "Tell me more about Map the Power!"
    expect(page).to have_text "What are your research interests? What are you hoping to use LittleSis for?"
  end

  scenario 'Fills out form and signs up' do
    counts = [User.count, UserProfile.count]

    fill_in 'user_user_profile_attributes_name_first', :with => user_info.first_name
    fill_in 'user_user_profile_attributes_name_last', :with => user_info.last_name
    fill_in 'user_email', :with => user_info.email
    fill_in 'user_username', :with => user_info.username
    fill_in 'user_password', :with => user_info.password
    fill_in 'user_password_confirmation', :with => user_info.password
    fill_in 'math_answer', :with => page.find('#math_number_one').value.to_i.public_send(page.find('#math_operation').value, page.find('#math_number_two').value.to_i)
    find(:css, "#terms_of_use").set(true)
    fill_in 'about-you-input', :with => user_info.about_you

    click_button 'Sign up'

    expect([User.count, UserProfile.count]).to eq counts.map { |x| x + 1 }
    expect(page.status_code).to eq 200
    expect(page).to have_current_path join_success_path
    expect(page).not_to have_selector "#signup-errors-alert"

    last_user = User.last
    expect(last_user.newsletter).to be true
    expect(last_user.map_the_power).to be false
  end

  scenario 'Fills out form and signs up with location field and checks map the power' do
    location = 'the center of the earth'

    fill_in 'user_user_profile_attributes_name_first', :with => user_info.first_name
    fill_in 'user_user_profile_attributes_name_last', :with => user_info.last_name
    fill_in 'user_email', :with => user_info.email
    fill_in 'user_username', :with => user_info.username
    fill_in 'user_password', :with => user_info.password
    fill_in 'user_password_confirmation', :with => user_info.password
    find(:css, "#terms_of_use").set(true)
    fill_in 'about-you-input', :with => user_info.about_you
    fill_in 'user_user_profile_attributes_location', :with => location

    fill_in 'math_answer', :with => page.find('#math_number_one').value.to_i.public_send(page.find('#math_operation').value, page.find('#math_number_two').value.to_i)

    find(:css, "#user_map_the_power").set(true)

    click_button 'Sign up'

    expect(UserProfile.last.location).to eql location

    last_user = User.last
    expect(last_user.email).to eql user_info.email
    expect(last_user.map_the_power).to be true
  end

  describe 'Attempting to signup with a username that is already taken' do
    let(:username) { random_username }

    before do
      create_basic_user_with_profile(username: username)
    end

    scenario 'Shows error message regarding the username' do
      counts = [User.count, UserProfile.count]

      fill_in 'user_user_profile_attributes_name_first', :with => user_info.first_name
      fill_in 'user_user_profile_attributes_name_last', :with => user_info.last_name
      fill_in 'user_email', :with => user_info.email
      fill_in 'user_username', :with => username # dfiferent than the above example
      fill_in 'user_password', :with => user_info.password
      fill_in 'user_password_confirmation', :with => user_info.password
      find(:css, "#terms_of_use").set(true)
      fill_in 'about-you-input', :with => user_info.about_you
      fill_in 'math_answer', :with => page.find('#math_number_one').value.to_i.public_send(page.find('#math_operation').value, page.find('#math_number_two').value.to_i)
      click_button 'Sign up'

      expect([User.count, UserProfile.count]).to eq counts

      expect(page.status_code).to eq 200
      page_has_selector 'h2', text: 'Get Involved!'
      page_has_selector "#signup-errors-alert"
      expect(page.find("#signup-errors-alert")).to have_text "The username -- #{username} -- has already been taken"
    end
  end

  scenario 'answering the math problem incorrectly' do
    counts = [User.count, UserProfile.count]

    fill_in 'user_user_profile_attributes_name_first', :with => user_info.first_name
    fill_in 'user_user_profile_attributes_name_last', :with => user_info.last_name
    fill_in 'user_email', :with => user_info.email
    fill_in 'user_username', :with => user_info.username
    fill_in 'user_password', :with => user_info.password
    fill_in 'user_password_confirmation', :with => user_info.password
    answer = page.find('#math_number_one').value.to_i.public_send(page.find('#math_operation').value, page.find('#math_number_two').value.to_i)
    fill_in 'math_answer', :with => answer - 1
    find(:css, "#terms_of_use").set(true)
    fill_in 'about-you-input', :with => user_info.about_you

    click_button 'Sign up'

    expect([User.count, UserProfile.count]).to eq counts
    expect(page.status_code).to eq 200
    expect(page).to have_selector "#signup-errors-alert"
  end
end
