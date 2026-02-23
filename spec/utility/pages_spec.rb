describe Pages do
  specify do
    expect(Pages::HTML.keys).to eq %w[disclaimer terms_of_use privacy_policy cookie_policy about]
  end

  specify do
    expect(Pages.get(:disclaimer, :en)[0..2]).to eq '<h1'
    expect(Pages.get(:disclaimer, :es)[0..2]).to eq '<h1'
  end

  specify do
    expect(Pages.get(:terms_of_use, :en)[0..2]).to eq '<h1'
    expect(Pages.get(:terms_of_use, :es)[0..2]).to eq '<h1'
  end

  specify do
    expect(Pages.get(:privacy_policy, :en)[0..2]).to eq '<h1'
    expect(Pages.get(:privacy_policy, :es)[0..2]).to eq '<h1'
  end

  specify do
    expect(Pages.get(:cookie_policy, :en)[0..2]).to eq '<h1'
    expect(Pages.get(:cookie_policy, :es)[0..2]).to eq '<h1'
  end

  specify do
    expect(Pages.get(:disclaimer, :en)).to eq Pages.get(:disclaimer, :pl)
  end

  specify do
    expect(Pages.get(:terms_of_use, :en)).to eq Pages.get(:terms_of_use, :pl)
  end

  specify do
    expect(Pages.get(:privacy_policy, :en)).to eq Pages.get(:privacy_policy, :pl)
  end

  specify do
    expect(Pages.get(:cookie_policy, :en)).to eq Pages.get(:cookie_policy, :pl)
  end
end
