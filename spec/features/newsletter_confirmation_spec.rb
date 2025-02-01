describe 'Newsletters Signing' do
  let(:email) { Faker::Internet.email }

  specify 'subscribing' do
    visit '/newsletters/signup'

    expect(page).to have_checked_field(id: "newsletters_tags_newsletter")
    fill_in 'Email', with: email

    click_button 'Submit'

    expect(page).to have_text "Please check your email shortly"
  end

  specify 'confirming' do
    confirmation_link = NewslettersConfirmationLink.create(Faker::Internet.email, ['newsletter'])
    expect(NewsletterSignupJob).to receive(:perform_later)
                                     .with(confirmation_link.email, [:newsletter]).once
    visit confirmation_link.url
    expect(page).to have_text "You are now subscribed!"
    visit confirmation_link.url
    expect(page).to have_text "The link appears to be expired"
  end
end
