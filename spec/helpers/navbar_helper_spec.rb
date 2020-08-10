describe NavbarHelper do
  specify 'navbar_header_link' do
    html = helper.navbar_header_link('foo', href: '/example')
    expect(html.slice(0, 2)).to eq '<a'
    expect(html).to include 'href="/example"'
    expect(html).to include 'dropdown-toggle'
  end
end
