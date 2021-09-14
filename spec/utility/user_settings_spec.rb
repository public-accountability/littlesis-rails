describe UserSettings do
  it 'returns defaults and forwards methods' do
    expect(UserSettings.new.default_tag).to eq :oligrapher
    expect(UserSettings.new[:default_tag]).to eq :oligrapher
  end

  it 'accepts values' do
    expect(UserSettings.new(default_tag: :map_the_power).default_tag).to eq :map_the_power
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
    settings = UserSettings.load("{\"default_tag\":\"foobar\"}")

    expect(settings).to be_a UserSettings
    expect(settings.default_tag).to be :foobar
  end
end
