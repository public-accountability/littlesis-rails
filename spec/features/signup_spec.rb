require 'rails_helper'

feature "Signing up for an account", type: :feature do
  let(:user_info) do
    Struct
      .new(:first_name, :last_name, :email, :password, :username, :about_you)
      .new(Faker::Name.first_name, Faker::Name.last_name, Faker::Internet.email, Faker::Internet.password(8), Faker::Internet.user_name, Faker::Lovecraft.sentence)
  end

  before do
    visit new_user_registration_path
  end

  scenario 'User visits join page' do
    expect(page.status_code).to eq 200
    expect(page).to have_current_path new_user_registration_path

    page_has_selector 'h2', text: 'Get Involved!'
    page_has_selector 'h2', text: 'Data Summary'

    expect(page).to have_text "What are your research interests? What are you hoping to use LittleSis for?"
  end

  scenario 'Fills out form and signs up' do
    counts = [User.count, SfGuardUser.count, SfGuardUserProfile.count]

    fill_in 'user_sf_guard_user_profile_name_first', :with => user_info.first_name
    fill_in 'user_sf_guard_user_profile_name_last', :with => user_info.last_name
    fill_in 'user_email', :with => user_info.email
    fill_in 'user_username', :with => user_info.username
    fill_in 'user_password', :with => user_info.password
    fill_in 'user_password_confirmation', :with => user_info.password
    find(:css, "#terms_of_use").set(true)
    fill_in 'about-you-input', :with => user_info.about_you

    click_button 'Sign up'

    expect(counts.map { |x| x + 1 }).to eql [User.count, SfGuardUser.count, SfGuardUserProfile.count]
    expect(page.status_code).to eq 200
    expect(page).to have_current_path join_success_path

    expect(page).not_to have_selector "#signup-errors-alert"
  end

  scenario 'Fills out form and signs up with location field' do
    location = 'the center of the earth'

    fill_in 'user_sf_guard_user_profile_name_first', :with => user_info.first_name
    fill_in 'user_sf_guard_user_profile_name_last', :with => user_info.last_name
    fill_in 'user_email', :with => user_info.email
    fill_in 'user_username', :with => user_info.username
    fill_in 'user_password', :with => user_info.password
    fill_in 'user_password_confirmation', :with => user_info.password
    find(:css, "#terms_of_use").set(true)
    fill_in 'about-you-input', :with => user_info.about_you
    fill_in 'user_sf_guard_user_profile_location', :with => location

    click_button 'Sign up'

    expect(SfGuardUserProfile.last.location).to eql location
  end

  context 'Attempting to signup with a username that is already taken' do
    let(:username) { Faker::Internet.user_name }
    let!(:user) do
      sf_user = create(:sf_guard_user)
      create(:sf_guard_user_profile, public_name: username, user_id: sf_user.id)
      create(:user, sf_guard_user_id: sf_user.id, username: username)
    end

    scenario 'Shows error message regarding the username' do
      counts = [User.count, SfGuardUser.count, SfGuardUserProfile.count]

      fill_in 'user_sf_guard_user_profile_name_first', :with => user_info.first_name
      fill_in 'user_sf_guard_user_profile_name_last', :with => user_info.last_name
      fill_in 'user_email', :with => user_info.email
      fill_in 'user_username', :with => username # dfiferent than the above example
      fill_in 'user_password', :with => user_info.password
      fill_in 'user_password_confirmation', :with => user_info.password
      find(:css, "#terms_of_use").set(true)
      fill_in 'about-you-input', :with => user_info.about_you

      click_button 'Sign up'

      expect(counts).to eql [User.count, SfGuardUser.count, SfGuardUserProfile.count]

      expect(page.status_code).to eq 200
      page_has_selector 'h2', text: 'Get Involved!'
      page_has_selector "#signup-errors-alert"
      expect(page.find("#signup-errors-alert")).to have_text "The username -- #{username} -- has already been taken"

    end
  end
end
