describe 'PagesConstraint' do
  class FakeRequest
    def initialize(url)
      define_singleton_method(:fullpath) { url }
    end
  end

  before do
    expect(YAML).to receive(:load_file)
                     .with(Rails.root.join('config', 'pages.yml'))
                     .and_return(['about', 'features'])
  end

  it 'loads lists from pages.yml and set @pages' do
    expect(PagesConstraint.new.instance_variable_get('@pages'))
      .to eq ['/about', '/features', '/about/edit', '/features/edit' ]
  end

  it 'matches "about"' do
    pc = PagesConstraint.new
    expect(pc.matches?(FakeRequest.new('/about'))).to be true
    expect(pc.matches?(FakeRequest.new('/features'))).to be true
  end

  it 'matches edit pages' do
    pc = PagesConstraint.new
    expect(pc.matches?(FakeRequest.new('/about/edit'))).to be true
    expect(pc.matches?(FakeRequest.new('/features/edit'))).to be true
  end

  it 'does not match pages that are not defined in the file' do
    pc = PagesConstraint.new
    expect(pc.matches?(FakeRequest.new('/fake_page'))).to be false
  end
end
