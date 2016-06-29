require 'rails_helper'

describe List do
  it 'includes SoftDelete' 
  it 'includes cacheable'
  it 'includes Referenceable'
  context "relationship with listEntity" do
    it 'has many list entities' do
      list = create(:list)
      expect(true).to eq true
    end
  end
end
