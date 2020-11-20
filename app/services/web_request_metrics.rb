# frozen_string_literal: true

class WebRequestMetrics
  attr_reader :now, :then

  PAGE_FILTERS = [%r{/oligrapher/[[:digit:]]+/lock}i,
                  %r{/home/dashboard},
                 %r{/login},
                 %r{/entities/validate}].freeze

  def initialize(time: 1.day, limit: 20)
    # Because WebRequest is generated daily via logrotate
    # there can be a delay between requests being generated.
    # running logrotate -f /etc/logrotate.d/nginx before this
    # can help ensure the logs are up to date.
    @now = WebRequest.last.time
    @then = @now - time
    @limit = limit
  end

  def success_rate
    (relation.where('status <= 400').count / total_requests.to_f)
  end

  def total_requests
    @total_requests ||= relation.count
  end

  def uniq_ips
    @uniq_ips ||= relation.distinct.count(:remote_address)
  end

  def popular_pages
    @popular_pages ||= relation
                         .select('uri, count(*) as c')
                         .group('uri')
                         .order('c desc')
                         .limit(@limit * 100)
                         .to_a.lazy
                         .filter { |wr| PAGE_FILTERS.none? { |f| f.match?(wr.uri) } }
                         .take(@limit)
                         .map(&:uri)
                         .force
  end

  def popular_errors
    @popular_errors ||= relation
                          .where('status >= 400')
                          .select('uri, status, count(*) as c')
                          .group('uri, status')
                          .order('c desc')
                          .limit(@limit)
                          .map(&:uri)
  end

  private

  def relation
    WebRequest.where('time >= ?', @then)
  end
end
