require 'rails_helper'

describe Tag do
  let(:tags) do
    [
      {
        'name' => 'oil',
        'description' => 'the reason for our planet\'s demise',
        'id' => 1
      },
      {
        'name' => 'nyc',
        'description' => 'anything related to New York City',
        'id' => 2
      }
    ]
  end
  let(:invalid_tags) { tags.dup.tap { |t| t[1]['id'] = 1 } }

  it "returns all tags" do
    expect(Tag.all).to eql tags
  end

  it "throws an argument error if ids not unique" do
    expect(YAML).to receive(:load).and_return(invalid_tags)

    Object.send(:remove_const, :Tag) # unload Tag class
    expect {
      load Rails.root.join('app', 'models', 'tag.rb') # reload tag class
    }.to raise_error(ArgumentError)
    
  end
  
end
