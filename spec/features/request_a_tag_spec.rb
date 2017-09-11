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
    expect(page).to have_selector '#request-tag-form'
    expect(page).to have_selector 'input#tag_name'
    expect(page).to have_selector 'textarea#tag_description'
    expect(page).to have_selector 'textarea#tag_additional'
    expect(page).to have_selector "button[type='submit']"
  end

  scenario 'After user submits a form, it sends an email to the staff' do
    
  end

end
