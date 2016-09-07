require 'rails_helper'

describe 'RelationshipDetails' do 

  it 'initializes details as an empty array' do 
      expect(RelationshipDetails.new(build(:relationship)).details).to eql []
  end

  describe 'title' do 
    it 'returns self unless it is a position, member, donation, or ownership relationship' do 
      expect(RelationshipDetails.new(build(:relationship, category_id: 2)).title.details).to eql []
      expect(RelationshipDetails.new(build(:relationship, category_id: 4)).title.details).to eql []
      expect(RelationshipDetails.new(build(:relationship, category_id: 6)).title.details).to eql []
    end
    
    it 'returns member if d1 is nil and category_id = 3' do 
      expect(RelationshipDetails.new(build(:relationship, category_id: 3)).title.details).to eql [ ['Title', 'member']]
    end
    
  end
  

end
