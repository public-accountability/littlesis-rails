# rubocop:disable Style/WordArray

describe RelationshipDetails do
  let(:position_relationship) do
    build(:relationship, category_id: 1, description1: 'boss', is_current: true, start_date: "1624")
  end

  let(:donation_rel) do
    build(:relationship,
          category_id: 5,
          description1: 'Campaign Contribution',
          start_date: '1900',
          end_date: '2000',
          amount: 7000,
          currency: :usd,
          filings: 2)
  end

  let(:bernie_house_relationship) do
    build(:relationship, category_id: 3, start_date: '1991', end_date: '2007',
                         entity: build(:person, name: 'Bernie Sanders'),
                         related: build(:us_house),
                         membership: build(:bernie_house_membership) )
  end

  describe 'title' do
    it 'returns self unless it is a position, member, donation, or ownership relationship' do
      expect(RelationshipDetails.new(build(:relationship, category_id: 2)).title.details).to eql []
      expect(RelationshipDetails.new(build(:relationship, category_id: 4)).title.details).to eql []
      expect(RelationshipDetails.new(build(:relationship, category_id: 6)).title.details).to eql []
    end

    it 'shows "member" for membership relationships missing description1' do
      expect(RelationshipDetails.new(build(:relationship, category_id: 3)).details)
        .to eql [%w[Title Member]]
    end
  end

  it 'returns details for position relationship' do
    position_relationship.position = build(:position, is_board: false, compensation: 25)
    details = [['Title', 'boss'], ['Start Date', '1624'], ['Is Current', 'yes'], ['Board member', 'no'], ['Compensation', '25 USD']]
    expect(RelationshipDetails.new(position_relationship).details).to eq details
  end

  it 'returns details for education relationship' do
    rel = build(:relationship, category_id: 2, description1: 'Undergraduate', is_current: false)
    rel.education = build(:education, degree_id: 6, is_dropout: true)
    expect(RelationshipDetails.new(rel).details)
      .to eql [['Type', 'Undergraduate'], ['Degree', "Bachelor's Degree"], ['Is Dropout', 'yes']]
  end

  it 'returns details for membership relationship' do
    rel = build(:relationship, category_id: 3, start_date: '2000', end_date: '2001')
    rel.membership = build(:membership, dues: 100)
    expect(RelationshipDetails.new(rel).details)
      .to eql [['Title', 'Member'], ['Start Date', '2000'], ['End Date', '2001'], ['Dues', '100 USD']]
  end

  it 'returns details for membership in U.S. house' do
    expect(RelationshipDetails.new(bernie_house_relationship).details)
      .to eq [['Title', 'Member'],
              ['Start Date', '1991'],
              ['End Date', '2007'],
              ['State', 'VT'],
              ['District', 'At-large'],
              ['Party', 'Independent']]
  end

  it 'returns details for family relationship' do
    rel = build(:relationship, category_id: 4, description1: 'Father', description2: 'Son')
    rel.entity = build(:person, name: 'Vader')
    rel.related = build(:person, name: 'Luke')
    expect(RelationshipDetails.new(rel).details).to eql [%w[Father Vader], %w[Son Luke]]
  end

  it 'returns details for donation relationship' do
    expect(RelationshipDetails.new(donation_rel).details)
      .to eql [['Type', 'Campaign Contribution'], ['Start Date', '1900'],
               ['End Date', '2000'], ['Amount', '7,000 USD'], ['FEC Filings', '2']]
  end

  it 'returns details for NYS donation relationship' do
    rel = build(:nys_donation_relationship, filings: 10, amount: 10_000, currency: 'USD')
    expect(RelationshipDetails.new(rel).details)
      .to eql [['Type', 'NYS Campaign Contribution'],
               ['Amount', '10,000 USD'], ['Filings', '10']]
  end

  it 'returns details for federal donation relationship' do
    rel = build(:federal_donation_relationship, filings: 10, amount: 10_000, currency: 'USD')
    expect(RelationshipDetails.new(rel).details)
      .to eql [['Type', 'Campaign Contribution'],
               ['Amount', '10,000 USD'], ['FEC Filings', '10']]
  end

  it 'returns details for transaction relationship' do
    rel = build(:relationship, category_id: 6, goods: 'jelly beans', is_current: true)
    expect(RelationshipDetails.new(rel).details)
      .to eql [['Is Current', 'yes'], ['Goods', 'jelly beans']]
  end

  it 'returns details for lobbying relationship' do
    rel = build(:relationship, category_id: 7, amount: 10, currency: 'USD')
    expect(RelationshipDetails.new(rel).details).to eql [['Amount', '10 USD']]
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
      .to eql [['X', 'Alice'], ['Y', 'Bob'], ['Is Current', 'yes']]
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
    let(:vader) { build(:person, name: 'Vader') }
    let(:luke) { build(:person, name: 'Luke') }

    let(:relationship) do
      build(:relationship,
            category_id: 4,
            description1: 'Father',
            description2: 'Son',
            entity: vader,
            related: luke)
    end

    it 'returns nil if given a entity that not in the relationship' do
      expect(RelationshipDetails.new(relationship).family_details_for(build(:person))).to be nil
    end

    it 'returns details for other person if given entity' do
      expect(RelationshipDetails.new(relationship).family_details_for(vader)).to eq %w[Son Luke]
      expect(RelationshipDetails.new(relationship).family_details_for(vader.id)).to eq %w[Son Luke]
    end

    it 'returns details for other person if given related' do
      expect(RelationshipDetails.new(relationship).family_details_for(luke)).to eq %w[Father Vader]
      expect(RelationshipDetails.new(relationship).family_details_for(luke.id)).to eq %w[Father Vader]
      expect(RelationshipDetails.new(relationship).family_details_for(luke.id.to_s)).to eq %w[Father Vader]
    end
  end
end

# rubocop:enable Style/WordArray
