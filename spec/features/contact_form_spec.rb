require 'email_spec'
require 'email_spec/rspec'

feature 'Contact Us Form' do
  let(:user) { create_basic_user }
  let(:email) { Faker::Internet.email }
  let(:message) { Faker::Lorem.paragraph }
  let(:name) { Faker::Name.first_name }

  scenario 'Sending us a message', :run_jobs do
    visit contact_index_path
    successfully_visits_page contact_index_path

    fill_in 'Name', with: name
    fill_in 'Email', with: email
    select 'Press inquiry', from: 'Subject'
    fill_in 'Message', with: message

    click_button 'submit'
    expect(page.html).to include 'Your message has been sent. Thank you!'

    email = last_email_sent
    expect(email).to have_subject('Contact Us: Press inquiry')
    expect(email.body).to have_text(message)
  end

  scenario 'Sending us a message in Russian' do
    visit contact_index_path
    successfully_visits_page contact_index_path

    fill_in 'Name', with: name
    fill_in 'Email', with: email
    select 'Press inquiry', from: 'Subject'
    fill_in 'Message', with: 'Что пройдет, то будет мил'

    click_button 'submit'
    expect(page.html).to include CGI.escapeHTML(ErrorsController::YOU_ARE_SPAM)
    expect { last_email_sent }.to raise_error(RuntimeError, 'No email has been sent!')
  end

  # TODO Can we replace this test?
  #scenario 'Solving the math captcha incorrectly' do
  #  visit contact_index_path
  #  successfully_visits_page contact_index_path
  #
  #  fill_in 'Name', with: name
  #  fill_in 'Email', with: email
  #  select 'Press inquiry', from: 'Subject'
  #  fill_in 'Message', with: message
  #
  #  find('#contact_form_math_captcha_answer').fill_in(with: 10_000)
  #
  #  click_button 'submit'
  #  expect(page.html).to include 'Incorrect solution to the math problem. Please try again.'
  #end

  scenario 'a bot finds the honeypot' do
    visit contact_index_path
    successfully_visits_page contact_index_path

    fill_in 'Name', with: name
    fill_in 'Email', with: email
    select 'Press inquiry', from: 'Subject'
    fill_in 'Message', with: message
    fill_in 'contact_form[very_important_wink_wink]', with: 'spam'

    click_button 'submit'
    expect(page.html).to include CGI.escapeHTML(ErrorsController::YOU_ARE_SPAM)
  end

  scenario 'logged-in user sends a message' do
    login_as(user, scope: :user)

    visit contact_index_path
    successfully_visits_page contact_index_path

    expect(page).not_to have_selector '.h-captcha'
    expect(page.html).to include user.username
    select 'Press inquiry', from: 'Subject'
    fill_in 'Message', with: message

    expect(NotificationMailer).to receive(:contact_email).once.and_return(double(deliver_later: :mail))

    click_button 'submit'
    expect(page.html).to include 'Your message has been sent. Thank you!'

    logout(:user)
  end
end
