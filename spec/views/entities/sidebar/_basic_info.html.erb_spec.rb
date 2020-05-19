describe "sidebar/basic_info" do
  before do
    @org = create(:org, start_date: '1978-01-01', website: 'http://example.com')
    assign(:entity, @org)
    render partial: 'entities/sidebar/basic_info.html.erb',
           locals: { basic_info: @org.basic_info }
  end

  it 'has one table' do
    css 'table', count: 1
  end

  it 'has one link' do
    css 'a'
  end

  it 'turns "start_date" into "Start date"' do
    expect(rendered).to match '<strong>Start date</strong>'
  end
end
