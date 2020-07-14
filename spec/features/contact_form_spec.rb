describe 'Contact Us Form' do
  let(:email) { Faker::Internet.email }
  let(:message) { Faker::Lorem.paragraph }
  let(:name) { Faker::Name.first_name }

  scenario 'Sending us a message' do
    expect(NotificationMailer)
      .to receive(:contact_email)
            .once.with(email: email, message: message, name: name, subject: "Press inquiry")
            .and_return(double(deliver_later: nil))

    visit '/contact'
    successfully_visits_page '/contact'

    fill_in 'name', with: name
    fill_in 'email', with: email
    select "Press inquiry", from: "subject"
    fill_in 'message', with: message

    answer = page.find('#math_number_one').value.to_i.public_send(page.find('#math_operation').value, page.find('#math_number_two').value.to_i)
    fill_in 'math_answer', :with => answer

    click_button 'submit'
    expect(page.html).to include 'Your message has been sent. Thank you!'
  end

  scenario 'Sending us a message in Russian' do
    expect(NotificationMailer).not_to receive(:contact_email)

    visit '/contact'
    successfully_visits_page '/contact'

    fill_in 'name', with: name
    fill_in 'email', with: email
    select "Press inquiry", from: "subject"
    fill_in 'message', with: "Что пройдет, то будет мил"

    answer = page.find('#math_number_one').value.to_i.public_send(page.find('#math_operation').value, page.find('#math_number_two').value.to_i)
    fill_in 'math_answer', :with => answer

    click_button 'submit'
    expect(page.html).to include CGI.escapeHTML(ErrorsController::YOU_ARE_SPAM)
  end

  scenario 'Solving the math captcha incorrectly' do
    expect(NotificationMailer).not_to receive(:contact_email)
    visit '/contact'
    successfully_visits_page '/contact'

    fill_in 'name', with: name
    fill_in 'email', with: email
    select "Press inquiry", from: "subject"
    fill_in 'message', with: message

    fill_in 'math_answer', :with => 10_000

    click_button 'submit'
    expect(page.html).to include 'Incorrect solution to the math problem. Please try again.'
  end

  scenario 'a bot finds the honeypot' do
    expect(NotificationMailer).not_to receive(:contact_email)
    visit '/contact'
    successfully_visits_page '/contact'

    fill_in 'name', with: name
    fill_in 'email', with: email
    select "Press inquiry", from: "subject"
    fill_in 'message', with: message

    fill_in 'very_important_wink_wink', with: 'spam'

    click_button 'submit'
    expect(page.html).to include CGI.escapeHTML(ErrorsController::YOU_ARE_SPAM)
  end
end
