describe NewRecordMetrics do
  let(:start_time) { 1.month.ago }
  let(:end_time) { Time.current }
  let(:trange) { start_time..end_time }

  before do
    allow(Entity).to receive(:where).with(created_at: trange).and_return(double(count: 1))
    allow(Relationship).to receive(:where).with(created_at: trange).and_return(double(count: 2))
    allow(List).to receive(:where).with(created_at: trange).and_return(double(count: 3))
    allow(NetworkMap).to receive(:where).with(created_at: trange).and_return(double(count: 4))
  end

  specify do
    metrics = NewRecordMetrics.new(start_time, end_time)
    expect(metrics.entity).to eq 1
    expect(metrics.relationship).to eq 2
    expect(metrics.list).to eq 3
    expect(metrics.network_map).to eq 4
  end
end
