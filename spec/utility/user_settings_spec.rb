describe UserSettings do
  it 'returns defaults and forwards methods' do
    expect(UserSettings.new.oligrapher_beta).to be false
    expect(UserSettings.new[:oligrapher_beta]).to be false
  end

  it 'accepts values' do
    expect(UserSettings.new(oligrapher_beta: true).oligrapher_beta).to be true
  end

  it 'silently ignores invalid attributes' do
    expect { UserSettings.new(fake_settings: 'foobar') }.not_to raise_error
  end

  it 'dumps as json string' do
    expect(UserSettings.dump(UserSettings.new)).to be_a String
    expect do
      JSON.parse(UserSettings.dump(UserSettings.new))
    end.not_to raise_error
  end

  it 'loads from json_string' do
    settings = UserSettings.load("{\"oligrapher_beta\":true}")

    expect(settings).to be_a UserSettings
    expect(settings.oligrapher_beta).to be true
  end
end
