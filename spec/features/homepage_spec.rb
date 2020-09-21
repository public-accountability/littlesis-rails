describe 'Homepage' do
  let(:entity) { create(:entity_org) }
  let(:list) { create(:list) }

  before do
    allow_any_instance_of(HomeController).to receive(:carousel_entities).and_return([entity])
    stub_const 'HomeController::DOTS_CONNECTED_LISTS', [[list.id, 'Corporate fat cats']]
  end

  feature 'visiting the home page' do
    before { visit '/' }

    scenario 'anonymous user visiting the home page' do
      expect(page.status_code).to eq 200
      page_has_selector 'h1', text: 'LittleSis* is a free database of who-knows-who at the heights of business and government.'
    end
  end

  feature 'newsletter signup' do
    let(:email) { Faker::Internet.email }
    before { visit '/' }

    scenario 'signing up for the newsletter' do
      expect(NewsletterSignupJob).to receive(:perform_later).with(email, 'newsletter').once

      expect(page.status_code).to eq 200
      expect(page).not_to have_selector '#newsletter-thankyou'

      fill_in 'newsletter-signup-form-email', with: email
      click_button 'Join!'

      successfully_visits_page '/?nlty=yes'

      page_has_selector '#newsletter-thankyou',
                        text: "Thank you! You've been added to our newsletter."

      expect(page).not_to have_selector '#newsletter-signup-form'
    end

    scenario 'super advanced™ spam bot protection' do
      expect(NewsletterSignupJob).not_to receive(:perform_later)
      fill_in 'newsletter-signup-form-email', with: email
      fill_in 'very_important_wink_wink', with: "i'm a bot and i don't know any better"
      click_button 'Join!'
      successfully_visits_page '/?nlty=yes'
    end
  end

  feature 'Beta Version Indicator' do
    context 'without beta enabled' do
      it 'shows donation button' do
        visit '/'
        page_has_selector '#top_donate_link'
        page_has_no_selector '#nabar-beta-notice'
      end
    end

    context 'with beta enabled' do
      before do
        stub_const('APP_CONFIG', APP_CONFIG.merge('beta' => true))
      end

      it 'hides donation button' do
        visit '/'
        page_has_no_selector '#top_donate_link'
        page_has_selector '#navbar-beta-notice'
      end
    end
  end
end
