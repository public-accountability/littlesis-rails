describe LinksViewRefereshJob, type: :job do
  include ActiveJob::TestHelper

  specify do
    expect(Link).to receive(:refresh_materialized_view).once
    expect { LinksViewRefereshJob.perform_later }.to have_enqueued_job.on_queue('default')
    perform_enqueued_jobs
  end
end
