describe Pages do
  specify do
    # expect(Pages::HTML.keys).to eq %i[disclaimer about]
    expect(Pages.get(:disclaimer, :en)[0..2]).to eq '<h1'
    expect(Pages.get(:disclaimer, :es)[0..2]).to eq '<h1'
  end
end
