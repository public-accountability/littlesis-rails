describe WebRequestMetrics do
  subject(:metrics) { WebRequestMetrics.new }

  before do
    create(:web_request, uri: '/maps', time: 10.minutes.ago)
    create(:web_request, uri: '/lists', time: 8.minutes.ago)
    create(:web_request, uri: '/lists', time: 6.minutes.ago)
    create(:web_request, uri: '/bad_page', status: 500, time: 4.minutes.ago)
    create(:web_request, uri: '/', time: 2.days.ago)
  end

  it 'calculates requests count and success rate' do
    expect(metrics.total_requests).to eq 4
    expect(metrics.success_rate).to eq 0.75
    expect(metrics.uniq_ips).to eq 4
  end

  it 'calculates popular pages and popular errors' do
    expect(metrics.popular_pages.first).to eq '/lists'
    expect(metrics.popular_errors).to eq ['/bad_page']
  end
end
