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
      expect(RelationshipDetails.new(build(:relationship, category_id: 3)).details).to eql [ ['Title', 'member']]
    end
    
  end

  it 'returns details for position relationship' do 
    rel = build(:relationship, category_id: 1, description1: 'boss', is_current: true, start_date: "1624")
    rel.position = build(:position, is_board: false, compensation: 25)
    expect(RelationshipDetails.new(rel).details).to eql [ ['Title', 'boss'], ['Start Date', '1624'], ['Is Current', 'yes'], ['Board member', 'no'], ['Compensation', '25'] ]
  end
  
  it 'returns details for education relationship' do 
    rel = build(:relationship, category_id: 2, description1: 'Undergraduate', is_current: false)
    rel.education = build(:education, degree_id: 6, is_dropout: true)
    expect(RelationshipDetails.new(rel).details).to eql [ ['Type', 'Undergraduate'], ['Degree', "Bachelor's Degree"], ['Is Dropout', 'yes'] ]
  end
  
  it 'returns details for membership relationship' do 
    rel = build(:relationship, category_id: 3, start_date: '2000', end_date: '2001')
    rel.membership = build(:membership, dues: 100)
    expect(RelationshipDetails.new(rel).details).to eql [ ['Title', 'member'], ['Start Date', '2000'], ['End Date', '2001'], ['Dues', '100']]
  end
  
  it 'returns details for family relationship' do 
    rel = build(:relationship, category_id: 4, description1: 'Father', description2: 'Son')
    rel.entity = build(:person, name: 'Vader')
    rel.related = build(:person, name: 'Luke')
    expect(RelationshipDetails.new(rel).details)
      .to eql [ ['Father', 'Vader'], ['Son', 'Luke'] ]
  end

end
