describe NewsletterSignupJob, type: :job do
  include ActiveJob::TestHelper
  let(:email_address) { Faker::Internet.email }
  let(:user) { create_basic_user }

  it 'creates a job' do
    expect { NewsletterSignupJob.perform_later(email_address) }
      .to have_enqueued_job.on_queue('default')
  end

  describe 'submitting a User' do
    it 'signups the user using #signup' do
      expect(ActionNetwork).to receive(:signup).with(user).once
      NewsletterSignupJob.perform_later(user)
      perform_enqueued_jobs
    end
  end

  describe 'Newsletter Signup' do
    it 'signups the user using #add_email_to_newsletter' do
      expect(ActionNetwork).to receive(:add_email_to_newsletter).with(email_address).once
      NewsletterSignupJob.perform_later(email_address, 'newsletter')
      perform_enqueued_jobs
    end
  end

  describe 'PAI Signup' do
    it 'signups the user using #add_email_to_pai' do
      expect(ActionNetwork).to receive(:add_email_to_pai).with(email_address).once
      NewsletterSignupJob.perform_later(email_address, 'pai')
      perform_enqueued_jobs
    end
  end

  describe 'Press Signup' do
    it 'signups the user using #add_email_to_press' do
      expect(ActionNetwork).to receive(:add_email_to_press).with(email_address).once
      NewsletterSignupJob.perform_later(email_address, 'press')
      perform_enqueued_jobs
    end
  end

  describe 'errors' do
    it 'rejects bad types' do
      expect { NewsletterSignupJob.perform_now(5) }
        .to raise_error(TypeError)
    end

    it 'rejects invalid signup types' do
      expect { NewsletterSignupJob.perform_now(email_address, 'alice-the-cat-fan-club')}
        .to raise_error(ArgumentError)
    end
  end
end
