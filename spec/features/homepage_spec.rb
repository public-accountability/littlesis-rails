require 'rails_helper'

describe 'Homepage' do
  let(:entity) { create(:entity_org) }
  let(:list) { create(:list) }

  before do
    allow_any_instance_of(HomeController).to receive(:carousel_entities).and_return([entity])
    stub_const("HomeController::DOTS_CONNECTED_LISTS", [[list.id, 'Corporate fat cats']])
  end

  feature 'visting the home page' do
    before { visit '/' }

    scenario 'anonymous user visiting the home page' do
      expect(page.status_code).to eq 200
      page_has_selector 'h1', text: 'LittleSis* is a free database of who-knows-who at the heights of business and government.'
    end
  end

  feature 'newsletter signup' do
    let(:email) { Faker::Internet.email }
    before { visit '/' }

    scenario 'sigining up for the newsletter' do
      expect(NewsletterSignupJob).to receive(:perform_later).with(email).once

      expect(page.status_code).to eq 200

      fill_in 'newsletter-signup-form-email', with: email
      click_button 'Join!'

      successfully_visits_page '/'

      # check for display of 'thank you!'
    end

    scenario 'super advanced™ spam bot protection' do
      expect(NewsletterSignupJob).not_to receive(:perform_later)
      fill_in 'newsletter-signup-form-email', with: email
      fill_in 'very_important_wink_wink', with: "i'm a bot and i don't know any better"
      click_button 'Join!'
      successfully_visits_page '/'
    end
  end
end
