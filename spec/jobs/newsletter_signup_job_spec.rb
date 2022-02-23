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
      expect(ActionNetwork).to receive(:signup).with(user, [:newsletter]).once
      NewsletterSignupJob.perform_later(user)
      perform_enqueued_jobs
    end
  end
end
