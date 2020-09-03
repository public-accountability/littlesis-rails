# Allows us to test the outcome of jobs from within things like feature tests
# by just adding :run_jobs to the spec
RSpec.configure do |c|
  c.around(:each, run_jobs: true) do |ex|
    orig = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
    ex.run
    ActiveJob::Base.queue_adapter = orig
  end
end
