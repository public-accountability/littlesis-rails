describe Pages do
  specify do
    expect(Pages::HTML.keys).to eq %w[disclaimer about]
  end

  specify do
    expect(Pages.get(:disclaimer, :en)[0..2]).to eq '<h1'
    expect(Pages.get(:disclaimer, :es)[0..2]).to eq '<h1'
  end

  specify do
    expect(Pages.get(:disclaimer, :en)).to eq Pages.get(:disclaimer, :pl)
  end
end
