describe AddressState do
  specify do
    expect(AddressState.abbreviation_map).to be_a Hash
    expect(AddressState.abbreviation_map.count).to eql 59
  end

  specify do
    expect(AddressState.state_abbr('Colorado')).to eq 'CO'
    expect(AddressState.state_abbr('Canada')).to eq nil
  end
end
