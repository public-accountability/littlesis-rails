RSpec.describe PagesHelper, type: :helper do
  it 'renders markdown' do
    expect(helper.render_markdown('hello')).to eql "<p>hello</p>\n"
  end
end
