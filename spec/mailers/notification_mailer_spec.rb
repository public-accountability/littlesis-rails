# rubocop:disable RSpec/NamedSubject

describe NotificationMailer, type: :mailer do
  before(:all) { ActiveJob::Base.queue_adapter = :test } # rubocop:disable RSpec/BeforeAfterAll

  describe '#contact_email' do
    let(:params) do
      { name: 'me', email: 'email@email.com', message: 'hey', subject: 'hi' }
    end

    let(:mail) { NotificationMailer.contact_email(params) }

    it 'has correct subject' do
      expect(mail.subject).to eql 'Contact Us: hi'
    end

    it 'has correct to' do
      expect(mail.to).to eq [APP_CONFIG['notification_to']]
    end

    it 'has correct from' do
      expect(mail.from).to eq [APP_CONFIG['default_from_email']]
    end

    it 'has correct reply_to' do
      expect(mail.reply_to).to eq [params[:email]]
    end

    it 'has message' do
      expect(mail.encoded).to include params[:message]
    end

    it 'sends email' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'sends email later' do
      expect { mail.deliver_later }
        .to have_enqueued_job.on_queue('mailers')
    end
  end

  describe '#signup_email' do
    let(:map_the_power) { false }
    let(:user) { create(:user, map_the_power: map_the_power) }
    let(:user_profile) { create(:user_profile, user: user, location: 'vienna') }
    let(:mail) { NotificationMailer.signup_email(user) }

    before do
      user_profile
      mail
    end

    it 'has correct subject' do
      expect(mail.subject).to include "New User Signup: #{user.username}"
    end

    it 'has correct to' do
      expect(mail.to).to eq [APP_CONFIG['notification_to']]
    end

    it 'has username' do
      expect(mail.encoded).to include "#{user.username} (#{user.id})"
    end

    it 'has name' do
      expect(mail.encoded).to include CGI.escapeHTML("#{user_profile.name_first} #{user_profile.name_last}")
    end

    it 'has location' do
      expect(mail.encoded).to include '<strong>Location:</strong> vienna'
    end

    it 'has email' do
      expect(mail.encoded).to include "<strong>Email:</strong> #{user.email}"
    end

    context 'when user is interested in map the power' do
      let(:map_the_power) { true }

      it 'interested in map the power' do
        expect(mail.encoded).to include "<strong>Interested in Map the Power:</strong> true"
      end
    end

    context 'when user is not interested in map the power' do
      let(:map_the_power) { false }

      it 'interested in map the power' do
        expect(mail.encoded).to include "<strong>Interested in Map the Power:</strong> false"
      end
    end

    it 'has reason' do
      expect(mail.encoded).to include user_profile.reason
    end

    it 'sends email' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'sends email later' do
      expect { mail.deliver_later }
        .to have_enqueued_job.on_queue('mailers')
    end
  end

  describe '#flag_email' do
    let(:user_flag) do
      UserFlag.create!({ 'email' => 'user@littlesis.org',
                         'justification' => 'something just does not look right',
                         'page' => 'https://littlesis.org/some_page' })
    end

    let(:mail) { NotificationMailer.flag_email(user_flag) }

    it 'has url, message, and email' do
      expect(mail.encoded).to include 'https://littlesis.org/some_page'
      expect(mail.encoded).to include 'something just does not look right'
      expect(mail.encoded).to include 'user@littlesis.org'
    end

    it 'sends email' do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'sends email later' do
      expect { mail.deliver_later }.to have_enqueued_job.on_queue('mailers')
    end
  end

  describe '#bug_report_email' do
    let(:params) do
      {
        'email' => 'user@littlesis.org',
        'type' => 'Bug Report',
        'page' => 'the bug reporting page',
        'summary' => 'BUGS ARE EVERYWHERE',
        'description' => 'bugs are crawling all over the place.',
        'expected' => 'everything should be perfect always'
      }
    end

    let(:mail) { NotificationMailer.bug_report_email(params) }

    it 'has correct subject' do
      expect(mail.subject).to eql 'Bug Report: BUGS ARE EVERYWHERE'
    end

    it 'has correct to' do
      expect(mail.to).to eq [APP_CONFIG['notification_to']]
    end

    it 'has correct from' do
      expect(mail.from).to eq [APP_CONFIG['default_from_email']]
    end

    it 'has params contents' do
      params.values.each do |val|
        expect(mail.encoded).to include val
      end
    end
  end

  describe '#tag_request_email' do
    subject { NotificationMailer.tag_request_email(user, params) }

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

    context 'with additional information filled out' do
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

      it "has merge justification" do
        expect(body).to have_text merge_request.justification
      end

      it "links to merge review page" do
        expect(body).to have_text merge_url(mode: 'review',
                                            request: merge_request.id)
      end
    end
  end

  describe "#deletion_request_email" do
    let(:user) { create(:really_basic_user) }
    let(:deletion_request) { create(:deletion_request, user: user) }
    let(:mail) { NotificationMailer.deletion_request_email(deletion_request) }

    it "mentions entity in subject line" do
      expect(mail.subject)
        .to eql "Deletion request received for #{deletion_request.entity.name}"
    end

    it "sets requester as reply_to" do
      expect(mail.reply_to).to eql [user.email]
    end

    it "sends email" do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    describe "body" do
      let(:body) { mail.body.raw_source }

      it "mentions requester" do
        expect(body).to have_text user.username
      end

      it "mentions deletion target" do
        expect(body).to have_text deletion_request.entity.name
      end

      it "has merge justification" do
        expect(body).to have_text deletion_request.justification
      end

      it "links to deletion review page" do
        expect(body)
          .to have_text review_deletion_requests_entity_url(id: deletion_request.id)
      end
    end
  end

  describe "sending list deletion request email" do
    let(:user) { create(:really_basic_user) }
    let(:list) { create(:list) }
    let(:req) { create(:list_deletion_request, user: user, type: 'ListDeletionRequest', list: list) }

    let(:mail) { NotificationMailer.list_deletion_request_email(req) }

    it 'sends email' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'email contains link to deletion request' do
      expect(mail.body.raw_source)
        .to have_text "/deletion_requests/lists/#{req.id}"
    end
  end

  describe "sending image deletion request email" do
    let(:user) { create(:really_basic_user) }
    let(:image) { create(:image, entity: create(:entity_person)) }
    let(:image_deletion_request) do
      create(:image_deletion_request, user: user, image: image)
    end

    let(:mail) { NotificationMailer.image_deletion_request_email(image_deletion_request) }

    it 'sends email' do
      expect { mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'email contains link to deletion request' do
      expect(mail.body.raw_source)
        .to have_text "/deletion_requests/images/#{image_deletion_request.id}"
    end
  end
end

# rubocop:enable RSpec/NamedSubject
