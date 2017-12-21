require "rails_helper"

describe NotificationMailer, type: :mailer do
  before(:all) do
    DatabaseCleaner.start
    ActiveJob::Base.queue_adapter = :test
  end
  after(:all) { DatabaseCleaner.clean }

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
    before(:each) do
      @sf_user = create(:sf_guard_user)
      @user = create(:user, sf_guard_user: @sf_user)
      @profile = create(:sf_guard_user_profile, user_id: @sf_user.id)
      @mail = NotificationMailer.signup_email(@user)
    end

    it 'has correct subject' do
      expect(@mail.subject).to include "New User Signup: #{@user.username}"
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

  describe '#bug_report_email' do
    before(:all) do
      @params = {
        'email' => 'user@littlesis.org',
        'type' => 'Bug Report',
        'page' => 'the bug reporting page',
        'summary' => 'BUGS ARE EVERYWHERE',
        'description' => 'bugs are crawling all over the place.',
        'expected' => 'everything should be perfect always'
      }

      @mail = NotificationMailer.bug_report_email(@params)
    end

    it 'has correct subject' do
      expect(@mail.subject).to eql 'Bug Report: BUGS ARE EVERYWHERE'
    end

    it 'has correct to' do
      expect(@mail.to).to eq [APP_CONFIG['notification_to']]
    end

    it 'has correct from' do
      expect(@mail.from).to eq [APP_CONFIG['notification_email']]
    end

    it 'has params contents' do
      @params.values.each do |val|
        expect(@mail.encoded).to include val
      end
    end
  end

  describe '#tag_request_email' do
    let(:user) { create_really_basic_user }
    let(:params) do
      {
        'tag_name' => 'cats',
        'tag_description' => 'cute and furry',
        'tag_additional' => ''
      }
    end

    let(:params_with_additional_info) do
      params.merge('tag_additional' => "what kind of website doesn't have tag related to cats!?")
    end

    subject { NotificationMailer.tag_request_email(user, params) }

    it 'sets correct subject' do
      expect(subject.subject).to eql "Tag Request: cats"
    end

    it 'sets reply_to header to be the user\'s email' do
      expect(subject.reply_to).to eql [user.email]
    end

    it "includes requester's username" do
      expect(subject.encoded).to include "Requester: #{user.username}"
    end

    it "includes requester email" do
      expect(subject.encoded).to include "Email: #{user.email}"
    end

    it "includes tag description" do
      expect(subject.encoded).to include params['tag_description']
    end

    it 'does not contain additional info section when blank' do
      expect(subject.encoded).not_to include "Additional information"
    end

    context 'additional information filled out' do
      subject { NotificationMailer.tag_request_email(user, params_with_additional_info) }

      it "includes additional information" do
        expect(subject.encoded).to include "Additional information"
        expect(subject.encoded).to include params_with_additional_info['tag_additional']
      end
    end

    it 'sends email' do
      expect { subject.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "#merge_request_email" do
    let(:user) { create(:really_basic_user) }
    let(:merge_request) { create(:merge_request, user: user) }
    let(:mail) { NotificationMailer.merge_request_email(merge_request) }

    it "mentions merge source in subject line" do
      expect(mail.subject).to eql "Merge request received for #{merge_request.source.name}"
    end

    it "sets requester as reply_to" do
      expect(mail.reply_to).to eql [user.email]
    end

    it "sends email " do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    describe "body" do
      let(:body) { mail.body.raw_source }

      it "mentions requester" do
        expect(body).to have_text user.username
      end

      it "mentions merge source" do
        expect(body).to have_text merge_request.source.name
      end

      it "mentions merge destination" do
        expect(body).to have_text merge_request.dest.name
      end

      it "links to merge review page" do
        expect(body).to have_text merge_url(mode: 'review',
                                            request: merge_request.id)
      end
    end
  end
end
