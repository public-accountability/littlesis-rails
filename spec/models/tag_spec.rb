require 'rails_helper'

describe Tag do
  let(:tags) do
    [
      {
        'name' => 'oil',
        'description' => 'the reason for our planet\'s demise'
      },
      {
        'name' => 'nyc',
        'description' => 'anything related to New York City'
      }
    ]
  end

  it "returns all tags" do
    expect(Tag.all).to eql tags
  end
end
