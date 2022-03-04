class ApplicationJob < ActiveJob::Base
  # see https://github.com/bensheldon/good_job#exceptions-retries-and-reliability and https://guides.rubyonrails.org/active_job_basics.html#exceptions
  retry_on StandardError, wait: :exponentially_longer, attempts: 20
end
