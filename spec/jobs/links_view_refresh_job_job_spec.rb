describe LinksViewRefreshJob, type: :job do
  include ActiveJob::TestHelper

  specify do
    allow(Link).to receive(:refresh_materialized_view).once
    expect { LinksViewRefreshJob.perform_later }.to have_enqueued_job.on_queue('default')
    perform_enqueued_jobs
  end
end
