require "rails_helper"

describe NotificationMailer, type: :mailer do
  before(:all) do
    DatabaseCleaner.start
    ActiveJob::Base.queue_adapter = :test
  end
  after(:all) do 
    DatabaseCleaner.clean
  end

  describe '#contact_email' do
    before do
      @params = { name: 'me', email: 'email@email.com', message: 'hey', subject: 'hi' }
      @mail = NotificationMailer.contact_email(@params)
    end

    it 'has correct subject' do
      expect(@mail.subject).to eql 'Contact Us: hi'
    end

    it 'has correct to' do
      expect(@mail.to).to eq [APP_CONFIG['notification_to']]
    end

    it 'has correct from' do
      expect(@mail.from).to eq [APP_CONFIG['notification_email']]
    end

    it 'has correct reply_to' do
      expect(@mail.reply_to).to eq [@params[:email]]
    end

    it 'has message' do
      expect(@mail.encoded).to include @params[:message]
    end

    it 'sends email' do
      expect { @mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'sends email later' do
      expect { @mail.deliver_later }
        .to have_enqueued_job.on_queue('mailers')
    end
  end

  describe '#signup_email' do
    before(:all) do
      @sf_user = create(:sf_guard_user)
      @user = create(:user, sf_guard_user: @sf_user)
      @profile = create(:sf_guard_user_profile, user_id: @sf_user.id)
      @mail = NotificationMailer.signup_email(@user)
    end

    it 'has correct subject' do
      expect(@mail.subject).to include 'New User Signup: user'
    end

    it 'has correct to' do
      expect(@mail.to).to eq [APP_CONFIG['notification_to']]
    end

    it 'has username' do
      expect(@mail.encoded).to include "#{@user.username} (#{@user.id})"
    end

    it 'has name' do
      expect(@mail.encoded).to include 'first last'
    end

    it 'has reason' do
      expect(@mail.encoded).to include 'research'
    end

    it 'sends email' do
      expect { @mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'sends email later' do
      expect { @mail.deliver_later }
        .to have_enqueued_job.on_queue('mailers')
    end
  end

  describe '#flag_email' do
    before(:all) do
      flag_params = {
        'email' => 'user@littlesis.org',
        'message' => 'something just does not look right',
        'url' => 'https://littlesis.org/some_page'
      }
      @mail = NotificationMailer.flag_email(flag_params)
    end

    it 'has url' do
      expect(@mail.encoded).to include 'https://littlesis.org/some_page'
    end

    it 'has message' do
      expect(@mail.encoded).to include 'something just does not look right'
    end

    it 'sends email' do
      expect { @mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'sends email later' do
      expect { @mail.deliver_later }
        .to have_enqueued_job.on_queue('mailers')
    end
  end
end
