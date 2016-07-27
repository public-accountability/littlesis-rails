require 'rails_helper'

describe 'OsLegacyMatcher' do 
  before(:all) do 
    DatabaseCleaner.start
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
    DatabaseCleaner.clean
  end
  
  describe '#initialize' do
    it 'stores relationship id in instance var' do 
      matcher = OsLegacyMatcher.new "123"
      expect(matcher.relationship_id).to eql("123") 
    end
  end

  describe '#find_filing' do
    it 'finds 2 filings' do 
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
    
    it 'finds the donation if the fec_filing_id is the crp_id' do 
      filing = build(:loeb_filing_one)
      filing_found = @matcher.corresponding_os_donation(filing)
      expect(filing_found).to eq(@donation_one)
    end

    it 'finds the donation if the fec_filing_id is the microfilm number' do 
      filing = build(:loeb_filing_two)
      filing_found = @matcher.corresponding_os_donation(filing)
      expect(filing_found).to eq(@donation_two)
    end
    
  end

  describe '#match_one' do 

    it 'calls no_donation if no donation is found' do 
      matcher = OsLegacyMatcher.new 555
      expect(matcher).to receive(:no_donation).with(@filing_one)
      expect(matcher).to receive(:corresponding_os_donation).and_return(nil)
      matcher.match_one @filing_one
    end
  end

end
