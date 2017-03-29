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
      expect(RelationshipDetails.new(build(:relationship, category_id: 3)).details).to eql [ ['Title', 'Member']]
    end
  end

  it 'returns details for position relationship' do
    rel = build(:relationship, category_id: 1, description1: 'boss', is_current: true, start_date: "1624")
    rel.position = build(:position, is_board: false, compensation: 25)
    expect(RelationshipDetails.new(rel).details)
      .to eql [['Title', 'boss'], ['Start Date', '1624'], ['Is Current', 'yes'], ['Board member', 'no'], ['Compensation', '$25']]
  end

  it 'returns details for education relationship' do
    rel = build(:relationship, category_id: 2, description1: 'Undergraduate', is_current: false)
    rel.education = build(:education, degree_id: 6, is_dropout: true)
    expect(RelationshipDetails.new(rel).details).to eql [ ['Type', 'Undergraduate'], ['Degree', "Bachelor's Degree"], ['Is Dropout', 'yes'] ]
  end

  it 'returns details for membership relationship' do
    rel = build(:relationship, category_id: 3, start_date: '2000', end_date: '2001')
    rel.membership = build(:membership, dues: 100)
    expect(RelationshipDetails.new(rel).details).to eql [ ['Title', 'Member'], ['Start Date', '2000'], ['End Date', '2001'], ['Dues', '$100']]
  end

  it 'returns details for family relationship' do
    rel = build(:relationship, category_id: 4, description1: 'Father', description2: 'Son')
    rel.entity = build(:person, name: 'Vader')
    rel.related = build(:person, name: 'Luke')
    expect(RelationshipDetails.new(rel).details).to eql [['Father', 'Vader'], ['Son', 'Luke']]
  end

  it 'returns details for donation relationship' do
    rel = build(:relationship, category_id: 5, description1: 'Campaign Contribution', start_date: '1900', end_date: '2000', amount: 7000, filings: 2)
    expect(RelationshipDetails.new(rel).details)
      .to eql [['Type', 'Campaign Contribution'], ['Start Date', '1900'], ['End Date', '2000'], ['Amount', '$7,000'], ['FEC Filings', '2']]
  end

  it 'returns details for transaction relationship' do
    rel = build(:relationship, category_id: 6, goods: 'jelly beans', is_current: true)
    expect(RelationshipDetails.new(rel).details).to eql [[ 'Is Current', 'yes'], ['Goods', 'jelly beans']]
  end

  it 'returns details for lobbying relationship' do
    rel = build(:relationship, category_id: 7, amount: 10)
    expect(RelationshipDetails.new(rel).details).to eql [['Amount', '$10']]
  end

  it 'returns details for social relationship' do
    rel = build(:relationship, category_id: 8, description1: 'Friend', description2: 'Best Friend')
    rel.entity = build(:person, name: 'Alice')
    rel.related = build(:person, name: 'Bob')
    expect(RelationshipDetails.new(rel).details)
      .to eql [['Friend', 'Alice'], ['Best friend', 'Bob']]
  end

  it 'returns details for professional relationships' do
    rel = build(:relationship, category_id: 9, description1: 'X', description2: 'Y', is_current: true)
    rel.entity = build(:person, name: 'Alice')
    rel.related = build(:person, name: 'Bob')
    expect(RelationshipDetails.new(rel).details)
      .to eql [[ 'X', 'Alice' ], ['Y', 'Bob'], ['Is Current', 'yes']]
  end

  it 'returns details for ownership relationships' do
    rel = build(:relationship, category_id: 10, description1: 'owner')
    rel.ownership = build(:ownership, percent_stake: 20, shares: 1500)
    expect(RelationshipDetails.new(rel).details)
      .to eql [['Title', 'owner'], ['Percent Stake', '20%'], ['Shares', '1.5 Thousand']]
  end

  it 'returns details for hierarchy relationship' do
    rel = build(:relationship, category_id: 11, description1: 'In charge')
    rel.entity = build(:person, name: 'Queen')
    expect(RelationshipDetails.new(rel).details)
      .to eql [['In charge', 'Queen']]
  end

  it 'returns details for generic relationship' do
    rel = build(:relationship, category_id: 12, description1: 'X', notes: '1234')
    rel.entity = build(:person, name: 'Y')
    expect(RelationshipDetails.new(rel).details)
      .to eql [['X', 'Y'], ['Notes', '1234']]
  end

  describe '#family_details_for' do
    before do
      @rel = build(:relationship, category_id: 4, description1: 'Father', description2: 'Son')
      @vadar = build(:person, name: 'Vader', id: rand(1000))
      @luke = build(:person, name: 'Luke', id: rand(1000))
      @rel.entity = @vadar
      @rel.related = @luke
    end

    it 'returns nil if given a entity not in the relationship' do
      @rando = build(:person, id: rand(1000))
      expect(RelationshipDetails.new(@rel).family_details_for(@rando)).to be nil
    end

    it 'returns details for other person if given entity' do
      expect(RelationshipDetails.new(@rel).family_details_for(@vadar)).to eql %w(Son Luke)
      expect(RelationshipDetails.new(@rel).family_details_for(@vadar.id)).to eql %w(Son Luke)
    end

    it 'returns details for other person if given related' do
      expect(RelationshipDetails.new(@rel).family_details_for(@luke)).to eql %w(Father Vader)
      expect(RelationshipDetails.new(@rel).family_details_for(@luke.id)).to eql %w(Father Vader)
      expect(RelationshipDetails.new(@rel).family_details_for(@luke.id.to_s)).to eql %w(Father Vader)
    end
  end
end
