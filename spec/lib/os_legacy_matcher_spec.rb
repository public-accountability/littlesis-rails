require 'rails_helper'
DatabaseCleaner.strategy = :transaction

describe 'OsLegacyMatcher' do 
  before(:all) do 
    Entity.skip_callback(:create, :after, :create_primary_ext)
    create(:loeb)
    create(:nrsc)
    @relationship = create(:loeb_donation)
    @filing_one = create(:loeb_filing_one, relationship_id: @relationship.id)
    @filing_two = create(:loeb_filing_two, relationship_id: @relationship.id)
    @donation_one = create(:loeb_donation_one)
    @donation_two =create(:loeb_donation_two)
    @matcher = OsLegacyMatcher.new @relationship.id
  end
  
  after(:all) do
    Entity.set_callback(:create, :after, :create_primary_ext)
  end
  
  describe '#initialize' do
    it 'stores relationship id in instance var' do 
      matcher = OsLegacyMatcher.new "123"
      expect(matcher.relationship_id).to eql("123") 
    end
  end

  describe '#find_filing' do
    it 'finds 2 filing' do 
      @matcher.find_filing
      expect(@matcher.filings.count).to eql(2)
    end
  end

  describe '#corresponding_os_donation' do
    
    it 'finds the donation if the fec id & cycle matches' do 
      filing = build(:loeb_filing_one, fec_filing_id: '1120620120011115314')
      filing_found = @matcher.corresponding_os_donation(filing)
      expect(filing_found).to eq(@donation_one)
    end
    
  end
  

end
