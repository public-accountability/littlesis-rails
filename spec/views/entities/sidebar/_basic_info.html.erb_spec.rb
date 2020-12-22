describe 'sidebar/basic_info' do
  let(:org) do
    create(:org, start_date: '1978-01-01', website: 'http://example.com')
  end

  before do
    assign(:entity, org)
    render partial: 'entities/sidebar/basic_info',
           locals: { basic_info: org.basic_info }
  end

  specify do
    css 'table', count: 1
    css 'a'
    expect(rendered).to match '<strong>Start date</strong>'
  end
end
