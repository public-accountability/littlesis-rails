require 'rails_helper'

describe NyMatch, type: :model do

  before(:all) do 
    DatabaseCleaner.start
  end
  
  after(:all) do 
    DatabaseCleaner.clean
  end
  
  it { should validate_presence_of(:ny_disclosure_id) }
  it { should validate_presence_of(:donor_id) }

  describe 'match' do 
    
    it 'Creates a new match' do 
      expect{NyMatch.match(1,1,1)}.to change{NyMatch.count}.by(1)
    end
    
    it 'Creates match with correct attributes' do 
      NyMatch.match(1,50,42)
      m = NyMatch.last
      expect(m.ny_disclosure_id).to eql 1
      expect(m.donor_id).to eql 50
      expect(m.matched_by).to eql 42
    end
    
    it 'Sets matched_by to be the system_user_id if no user is given' do 
      NyMatch.match(10,20)
      expect(NyMatch.last.matched_by).to eql 1
    end

    it 'Does not create a new match if the match already exits' do 
      NyMatch.match(10,20,5555)
      expect{NyMatch.match(10,20)}.not_to change{NyMatch.count}
    end

  end

end
