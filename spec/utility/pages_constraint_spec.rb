describe 'PagesConstraint' do
  class FakePagesRequest
    def initialize(url)
      define_singleton_method(:fullpath) { url }
    end
  end

  it 'matches "about"' do
    pc = PagesConstraint.new
    expect(pc.matches?(FakePagesRequest.new('/about'))).to be true
    expect(pc.matches?(FakePagesRequest.new('/features'))).to be true
  end

  it 'matches edit pages' do
    pc = PagesConstraint.new
    expect(pc.matches?(FakePagesRequest.new('/about/edit'))).to be true
    expect(pc.matches?(FakePagesRequest.new('/features/edit'))).to be true
  end

  it 'does not match pages invalid pages' do
    pc = PagesConstraint.new
    expect(pc.matches?(FakePagesRequest.new('/fake_page'))).to be false
  end
end
