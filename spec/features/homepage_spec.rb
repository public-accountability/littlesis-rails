describe 'Homepage' do
  let(:entity) { create(:entity_org) }
  let(:list) { create(:list) }
  let(:list_double) { class_double(List).as_stubbed_const }

  before do
    stub_const 'HomeController::DOTS_CONNECTED_LISTS', [[list.id, 'Corporate fat cats']]

    # So that HomeController#carousel_entities returns something
    list.add_entity(entity)
    allow(list_double).to receive(:find).and_return(list)
    allow(list_double).to receive(:exists?).and_return(true)
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
    let(:signup_job) { class_double(NewsletterSignupJob).as_stubbed_const }

    before do
      visit '/'
      allow(signup_job).to receive(:perform_later)
    end

    scenario 'signing up for the newsletter' do
      expect(page.status_code).to eq 200
      expect(page).not_to have_selector '#newsletter-thankyou'

      fill_in 'newsletter-signup-form-email', with: email
      click_button 'Join!'

      expect(page).to have_css('#newsletter-thankyou',
                               text: "Thank you! You've been added to our newsletter.")
      expect(page).not_to have_css('#newsletter-signup-form')

      expect(signup_job).to have_received(:perform_later).with(email, 'newsletter').once
    end

    scenario 'super advanced™ spam bot protection' do
      fill_in 'newsletter-signup-form-email', with: email
      fill_in 'newsletter_signup_form[very_important_wink_wink]', with: "i'm a bot and i don't know any better"
      click_button 'Join!'
      successfully_visits_page '/?nlty=yes'

      expect(signup_job).not_to have_received(:perform_later)
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
