describe Address do
  it 'has constant STREET_TYPES' do
    expect(Address::STREET_TYPES).to be_a Set
  end
end
