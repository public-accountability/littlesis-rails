require 'rails_helper'

describe AddressState do
  specify do
    expect(AddressState.abbreviation_map).to be_a Hash
    expect(AddressState.abbreviation_map.count).to eql 59
  end
end
