
describe ListsHelper do
  describe '#nil_string' do
    
    it 'returns "nil" if given nil' do
      expect(helper.nil_string(nil)).to eq("nil")
    end
    
    it 'returns the obj if not given nil' do 
      expect(helper.nil_string("something")).to eq("something")
    end
  end
end

