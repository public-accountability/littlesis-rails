require 'rails_helper'

describe Reference do
  
  describe 'ref_types' do    
    it 'has ref_types class var' do 
      r = Reference.new
      expect(r.ref_types[1]).to eql('Generic')
      expect(r.ref_types[2]).to eql('FEC Filing')
    end

    it 'has a ref_type default value of 1' do
      r = create(:ref, source: 'url', object_id: 1)
      expect(r.ref_type).to eq(1)
    end
  end
  
end
