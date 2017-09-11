require 'rails_helper'

feature 'Requesting a new tag', type: :feature do
  let(:user) { create_really_basic_user }

  before(:each) do
    login_as(user, scope: :user)
    visit "/tags/request"
  end

  after(:each) { logout(:user) }

  scenario 'Contains a form where the user can request a tag' do
    expect(page.status_code).to eq 200
    expect(page).to have_selector 'p', text: user.email
    expect(page).to have_selector '#request-tag-form'
    expect(page).to have_selector 'input#tag_name'
    expect(page).to have_selector 'textarea#tag_description'
    expect(page).to have_selector 'textarea#tag_additional'
    expect(page).to have_selector "button[type='submit']"
  end

  feature 'Email notifiation' do
    let(:params) do
      {
        'tag_name' => 'dogs',
        'tag_description' => 'dogs and their evil ways',
        'tag_additional' => ''
      }
    end

    scenario 'After user submits a form, it sends an email to the staff' do
      mailer = double("mailer")
      expect(mailer).to receive(:deliver_later).once

      expect(NotificationMailer).to receive(:tag_request_email)
                                      .with(user, hash_including(params))
                                      .and_return(mailer)

      expect(page).to have_current_path '/tags/request'
      fill_in 'tag_name', with: 'dogs'
      fill_in 'tag_description', with: 'dogs and their evil ways'
      click_button 'Submit'

      expect(page).to have_current_path home_dashboard_path
    end
  end
end
